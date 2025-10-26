//
//  FirebaseService.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import FirebaseFirestore

/// Firebase服务类，处理所有与Firestore的交互
class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Trip 相关操作
    
    /// 获取用户的所有旅行
    func fetchTrips(userId: String) async throws -> [Trip] {
        let snapshot = try await db.collection("trips")
            .whereField("userId", isEqualTo: userId)
            .order(by: "startDate", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Trip.self)
        }
    }
    
    /// 获取特定的旅行
    func fetchTrip(tripId: String) async throws -> Trip? {
        let document = try await db.collection("trips").document(tripId).getDocument()
        return try? document.data(as: Trip.self)
    }
    
    /// 监听旅行更新（实时更新）
    func listenToTrip(tripId: String, completion: @escaping (Trip?) -> Void) -> ListenerRegistration {
        return db.collection("trips").document(tripId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil)
                    return
                }
                let trip = try? snapshot.data(as: Trip.self)
                completion(trip)
            }
    }
    
    /// 创建新旅行
    func createTrip(trip: Trip) async throws -> String {
        let docRef = try db.collection("trips").addDocument(from: trip)
        return docRef.documentID
    }
    
    // MARK: - Photo 相关操作
    
    /// 保存照片信息到Firestore（包含Base64图片数据）
    func savePhoto(photo: Photo) async throws -> String {
        let docRef = try db.collection("photos").addDocument(from: photo)
        return docRef.documentID
    }
    
    /// 获取旅行的所有照片
    func fetchPhotos(tripId: String) async throws -> [Photo] {
        let snapshot = try await db.collection("photos")
            .whereField("tripId", isEqualTo: tripId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Photo.self)
        }
    }
    
    /// 获取用户的所有照片
    func fetchUserPhotos(userId: String) async throws -> [Photo] {
        let snapshot = try await db.collection("photos")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Photo.self)
        }
    }
    
    // MARK: - User 相关操作
    
    /// 获取或创建用户
    func fetchOrCreateUser(userId: String, name: String, email: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        
        if let user = try? document.data(as: User.self) {
            return user
        } else {
            let newUser = User(id: userId, name: name, email: email, createdAt: Date())
            try db.collection("users").document(userId).setData(from: newUser)
            return newUser
        }
    }
}
