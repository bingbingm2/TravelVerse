//
//  Trip.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import FirebaseFirestore

/// 代表一个完整的旅行
struct Trip: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var cityName: String
    var startDate: Date
    var endDate: Date
    var itinerary: [DayItinerary]
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case cityName
        case startDate
        case endDate
        case itinerary
        case createdAt
        case updatedAt
    }
}

/// 代表一天的行程
struct DayItinerary: Identifiable, Codable {
    var id: String = UUID().uuidString
    var day: Int
    var date: Date
    var places: [Place]
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case day
        case date
        case places
        case notes
    }
}

/// 代表一个地点
struct Place: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: String // 例如: "restaurant", "attraction", "hotel"
    var description: String?
    var startTime: String? // 例如: "09:00"
    var endTime: String? // 例如: "11:00"
    var realTimeInfo: String? // 队友web scraping获取的实时信息
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case latitude
        case longitude
        case category
        case description
        case startTime
        case endTime
        case realTimeInfo
    }
}
