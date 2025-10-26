//
//  TravelVerseApp.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import SwiftUI
import FirebaseCore

@main
struct TravelVerseApp: App {
    
    // 初始化Firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
