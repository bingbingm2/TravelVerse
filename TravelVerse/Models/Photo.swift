//
//  Photo.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import FirebaseFirestore

/// 代表用户上传的照片
struct Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var tripId: String
    var day: Int? // 第几天
    var placeId: String? // 关联到具体地点
    var placeName: String
    var imageBase64: String // Base64编码的图片数据
    var caption: String?
    var sentiment: [String]? // 情绪标签数组，如 ["Happy", "Excited", "Peaceful"]
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var cityName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case tripId
        case day
        case placeId
        case placeName
        case imageBase64
        case caption
        case sentiment
        case latitude
        case longitude
        case timestamp
        case cityName
    }
}
