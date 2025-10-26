//
//  PhotoViewModel.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

/// 管理照片上传的ViewModel
@MainActor
class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let firebaseService = FirebaseService.shared
    private let locationService = LocationService.shared
    
    var currentUserId: String = "demo_user_123"
    
    /// 上传照片（包含Base64图片数据）
    func uploadPhoto(
        image: UIImage,
        tripId: String,
        day: Int? = nil,
        placeId: String? = nil,
        placeName: String,
        caption: String?,
        sentiment: [String]? = nil,
        cityName: String
    ) async {
        isUploading = true
        errorMessage = nil
        successMessage = nil
        uploadProgress = 0.0
        
        // 智能压缩：先调整尺寸，再降低质量
        let finalImageData = compressImage(image, targetSizeKB: 900)
        
        guard let imageData = finalImageData else {
            errorMessage = "Failed to process image"
            isUploading = false
            return
        }
        
        // 检查最终大小
        let sizeInKB = imageData.count / 1024
        let sizeInMB = Double(imageData.count) / (1024 * 1024)
        
        print("✅ Image compressed to: \(sizeInKB) KB (\(String(format: "%.2f", sizeInMB)) MB)")
        
        // 如果还是太大（极少见），拒绝上传
        if imageData.count > 900000 {
            errorMessage = """
            Photo too large (\(String(format: "%.1f", sizeInMB)) MB)
            
            This photo is extremely large. Please:
            • Take a new photo with camera instead
            • Or use a photo editor to reduce size first
            
            Max size: 0.9 MB for Firestore storage
            """
            isUploading = false
            return
        }
        
        // 获取当前位置
        guard let location = locationService.currentLocation else {
            errorMessage = "Unable to get location. Please enable location permissions"
            isUploading = false
            return
        }
        
        do {
            // 1. 将图片转换为Base64字符串
            uploadProgress = 0.3
            let imageBase64 = imageData.base64EncodedString()
            
            // 2. 创建照片记录（包含Base64图片数据）
            uploadProgress = 0.5
            let photo = Photo(
                userId: currentUserId,
                tripId: tripId,
                day: day,
                placeId: placeId,
                placeName: placeName,
                imageBase64: imageBase64,
                caption: caption,
                sentiment: sentiment,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: Date(),
                cityName: cityName
            )
            
            // 3. 保存到Firestore
            uploadProgress = 0.8
            _ = try await firebaseService.savePhoto(photo: photo)
            
            uploadProgress = 1.0
            successMessage = "Photo uploaded successfully!"
            isUploading = false
            
            // 重新加载照片列表
            await loadPhotos(tripId: tripId)
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
            isUploading = false
            uploadProgress = 0.0
        }
    }
    
    /// 加载旅行的所有照片
    func loadPhotos(tripId: String) async {
        do {
            photos = try await firebaseService.fetchPhotos(tripId: tripId)
        } catch {
            errorMessage = "Failed to load photos: \(error.localizedDescription)"
        }
    }
    
    /// 加载用户的所有照片
    func loadUserPhotos() async {
        do {
            photos = try await firebaseService.fetchUserPhotos(userId: currentUserId)
        } catch {
            errorMessage = "Failed to load photos: \(error.localizedDescription)"
        }
    }
    
    /// 清除消息
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    /// 智能压缩图片：调整尺寸 + 降低质量
    private func compressImage(_ image: UIImage, targetSizeKB: Int) -> Data? {
        let targetBytes = targetSizeKB * 1024
        
        // 第一步：调整图片尺寸
        var resizedImage = image
        let maxDimension: CGFloat = 1200 // 最大边长1200像素
        
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // 第二步：调整压缩质量
        var compression: CGFloat = 0.7
        var imageData = resizedImage.jpegData(compressionQuality: compression)
        
        // 如果还是太大，逐步降低质量
        while let data = imageData, data.count > targetBytes && compression > 0.05 {
            compression -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compression)
        }
        
        // 如果还是太大，进一步缩小尺寸
        if let data = imageData, data.count > targetBytes {
            let furtherScale: CGFloat = 0.7
            let smallerSize = CGSize(
                width: resizedImage.size.width * furtherScale,
                height: resizedImage.size.height * furtherScale
            )
            
            UIGraphicsBeginImageContextWithOptions(smallerSize, false, 1.0)
            resizedImage.draw(in: CGRect(origin: .zero, size: smallerSize))
            if let smallerImage = UIGraphicsGetImageFromCurrentImageContext() {
                imageData = smallerImage.jpegData(compressionQuality: 0.5)
            }
            UIGraphicsEndImageContext()
        }
        
        return imageData
    }
}
