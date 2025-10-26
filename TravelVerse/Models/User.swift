//
//  User.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import FirebaseFirestore

/// 代表用户信息
struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var profileImageUrl: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImageUrl
        case createdAt
    }
}
