//
//  UploadPhotoView.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import SwiftUI
import PhotosUI

/// 上传照片视图 - 用户可以上传旅行中的照片（带位置信息）
struct UploadPhotoView: View {
    let trip: Trip
    let day: Int? // 可选：第几天
    let place: Place? // 可选：具体地点
    
    @StateObject private var viewModel = PhotoViewModel()
    @StateObject private var locationService = LocationService.shared
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var placeName = ""
    @State private var caption = ""
    @State private var showingImagePicker = false
    @State private var selectedSentiments: Set<String> = []
    @State private var customSentiment = ""
    
    @Environment(\.dismiss) var dismiss
    
    // 预设的情绪标签
    private let sentimentOptions = [
        "😊 Happy", "🥰 Loved", "😌 Peaceful", "🤩 Excited",
        "😮 Amazed", "🙏 Grateful", "😢 Nostalgic", "🤔 Thoughtful",
        "😍 Romantic", "🥳 Celebratory", "😎 Adventurous", "🤗 Warm",
        "😴 Relaxed", "🎉 Joyful", "💪 Inspired", "🤯 Mind-blown"
    ]
    
    // 初始化时设置默认值
    init(trip: Trip, day: Int? = nil, place: Place? = nil) {
        self.trip = trip
        self.day = day
        self.place = place
        // 如果有place，自动填充placeName
        _placeName = State(initialValue: place?.name ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upload Travel Photos")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let day = day, let place = place {
                        HStack {
                            Text("Day \(day)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(6)
                            
                            Text(place.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 照片选择器
                photoPickerSection
                
                // 照片预览
                if let image = selectedImage {
                    photoPreviewSection(image: image)
                }
                
                // 表单
                if selectedImage != nil {
                    formSection
                    
                    // 情绪标签选择
                    sentimentSection
                }
                
                // 位置信息
                locationSection
                
                // 上传按钮
                if selectedImage != nil {
                    uploadButton
                }
                
                // 已上传的照片
                uploadedPhotosSection
            }
            .padding()
        }
        .navigationTitle("Upload Photo")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("OK") {
                viewModel.clearMessages()
                selectedImage = nil
                selectedPhoto = nil
                placeName = ""
                caption = ""
                selectedSentiments.removeAll()
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearMessages()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            locationService.requestPermission()
            locationService.startUpdating()
            await viewModel.loadPhotos(tripId: trip.id ?? "")
        }
        .onDisappear {
            locationService.stopUpdating()
        }
    }
    
    // MARK: - 照片选择器部分
    private var photoPickerSection: some View {
        VStack(spacing: 16) {
            // 相册选择
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                    Text("Select from Album")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
            
            // 相机拍照
            Button {
                showCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Take Photo")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
        }
    }
    
    // MARK: - 照片预览
    private func photoPreviewSection(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 300)
            .cornerRadius(12)
            .shadow(radius: 5)
    }
    
    // MARK: - 表单部分
    private var formSection: some View {
        VStack(spacing: 16) {
            // 地点名称
            VStack(alignment: .leading, spacing: 8) {
                Text("Place Name *")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("e.g., Golden Gate Bridge", text: $placeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // 照片说明
            VStack(alignment: .leading, spacing: 8) {
                Text("Caption (Optional)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                TextField("Add some description...", text: $caption, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
    }
    
    // MARK: - 情绪标签部分
    private var sentimentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did you feel? 💭")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            // 预设情绪按钮
            FlowLayout(spacing: 8) {
                ForEach(sentimentOptions, id: \.self) { sentiment in
                    SentimentButton(
                        sentiment: sentiment,
                        isSelected: selectedSentiments.contains(sentiment)
                    ) {
                        toggleSentiment(sentiment)
                    }
                }
            }
            
            // 自定义情绪输入
            HStack(spacing: 8) {
                TextField("Add custom feeling...", text: $customSentiment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    if !customSentiment.isEmpty {
                        selectedSentiments.insert("✨ " + customSentiment)
                        customSentiment = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(customSentiment.isEmpty)
            }
            
            // 显示已选择的情绪
            if !selectedSentiments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected: \(selectedSentiments.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(Array(selectedSentiments), id: \.self) { sentiment in
                            HStack(spacing: 4) {
                                Text(sentiment)
                                    .font(.caption)
                                Button {
                                    selectedSentiments.remove(sentiment)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 位置信息
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Current Location")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            if let location = locationService.currentLocation {
                VStack(alignment: .leading, spacing: 4) {
                    // 显示城市名称
                    if let cityName = locationService.currentCityName {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(cityName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Text("Latitude: \(location.coordinate.latitude, specifier: "%.6f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Longitude: \(location.coordinate.longitude, specifier: "%.6f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Getting location...")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 上传按钮
    private var uploadButton: some View {
        Button {
            uploadPhoto()
        } label: {
            if viewModel.isUploading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Uploading... \(Int(viewModel.uploadProgress * 100))%")
                        .fontWeight(.semibold)
                }
            } else {
                Text("Upload Photo")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(canUpload ? Color.blue : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
        .disabled(!canUpload || viewModel.isUploading)
    }
    
    // MARK: - 已上传的照片
    private var uploadedPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.photos.isEmpty {
                Text("Uploaded Photos (\(viewModel.photos.count))")
                    .font(.headline)
                    .fontWeight(.bold)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.photos) { photo in
                            UploadedPhotoCard(photo: photo)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    private var canUpload: Bool {
        selectedImage != nil &&
        !placeName.isEmpty &&
        locationService.currentLocation != nil &&
        !viewModel.isUploading
    }
    
    private func toggleSentiment(_ sentiment: String) {
        if selectedSentiments.contains(sentiment) {
            selectedSentiments.remove(sentiment)
        } else {
            selectedSentiments.insert(sentiment)
        }
    }
    
    private func uploadPhoto() {
        guard let image = selectedImage else { return }
        
        Task {
            await viewModel.uploadPhoto(
                image: image,
                tripId: trip.id ?? "",
                day: day,
                placeId: place?.id,
                placeName: placeName,
                caption: caption.isEmpty ? nil : caption,
                sentiment: selectedSentiments.isEmpty ? nil : Array(selectedSentiments),
                cityName: trip.cityName
            )
        }
    }
}

// MARK: - 已上传照片卡片
struct UploadedPhotoCard: View {
    let photo: Photo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 从Base64显示图片
            if let imageData = Data(base64Encoded: photo.imageBase64),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(8)
            } else {
                // 如果Base64解码失败，显示占位符
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            }
            
            Text(photo.placeName)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            if let caption = photo.caption {
                Text(caption)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 显示情绪标签
            if let sentiments = photo.sentiment, !sentiments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(sentiments.prefix(3), id: \.self) { sentiment in
                            Text(sentiment)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        if sentiments.count > 3 {
                            Text("+\(sentiments.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(width: 150)
    }
}

// MARK: - Image Picker (相机)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - 情绪按钮组件
struct SentimentButton: View {
    let sentiment: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(sentiment)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - 流式布局组件
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationView {
        UploadPhotoView(trip: Trip(
            userId: "demo",
            cityName: "San Francisco",
            startDate: Date(),
            endDate: Date(),
            itinerary: [],
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
