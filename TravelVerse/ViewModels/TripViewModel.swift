//
//  TripViewModel.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import Combine
import FirebaseFirestore

/// 管理旅行数据的ViewModel
@MainActor
class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    nonisolated(unsafe) private var tripListener: ListenerRegistration?
    
    // 当前用户ID（在实际应用中，这应该来自认证系统）
    var currentUserId: String = "demo_user_123"
    
    /// 加载所有旅行
    func loadTrips() async {
        isLoading = true
        errorMessage = nil
        
        do {
            trips = try await firebaseService.fetchTrips(userId: currentUserId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load trips: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// 加载特定旅行
    func loadTrip(tripId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentTrip = try await firebaseService.fetchTrip(tripId: tripId)
            isLoading = false
        } catch {
            errorMessage = "Failed to load trip details: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// 实时监听旅行更新
    func listenToTrip(tripId: String) {
        tripListener?.remove()
        tripListener = firebaseService.listenToTrip(tripId: tripId) { [weak self] trip in
            self?.currentTrip = trip
        }
    }
    
    /// 停止监听
    nonisolated func stopListening() {
        tripListener?.remove()
        tripListener = nil
    }
    
    /// Create sample trip (for testing)
    func createSampleTrip() async {
        let startDate = Date()
        let sampleTrip = Trip(
            userId: currentUserId,
            cityName: "San Francisco",
            startDate: startDate,
            endDate: startDate.addingTimeInterval(86400 * 2), // 3 days total
            itinerary: [
                // Day 1: Classic SF Sightseeing
                DayItinerary(
                    day: 1,
                    date: startDate,
                    places: [
                        Place(
                            name: "Golden Gate Bridge",
                            address: "Golden Gate Bridge, San Francisco, CA",
                            latitude: 37.8199,
                            longitude: -122.4783,
                            category: "attraction",
                            description: "World-famous suspension bridge with stunning views",
                            startTime: "09:00",
                            endTime: "11:00",
                            realTimeInfo: "Clear weather, perfect for photos"
                        ),
                        Place(
                            name: "Fisherman's Wharf",
                            address: "Beach St & The Embarcadero, San Francisco, CA",
                            latitude: 37.8080,
                            longitude: -122.4177,
                            category: "attraction",
                            description: "Historic waterfront area with sea lions and shops",
                            startTime: "11:30",
                            endTime: "13:00",
                            realTimeInfo: "Sea lions are very active today"
                        ),
                        Place(
                            name: "Boudin Bakery",
                            address: "160 Jefferson St, San Francisco, CA",
                            latitude: 37.8087,
                            longitude: -122.4165,
                            category: "restaurant",
                            description: "Famous sourdough bread and clam chowder",
                            startTime: "13:15",
                            endTime: "14:30"
                        ),
                        Place(
                            name: "Alcatraz Island",
                            address: "Alcatraz Island, San Francisco, CA",
                            latitude: 37.8267,
                            longitude: -122.4230,
                            category: "attraction",
                            description: "Historic federal prison on an island",
                            startTime: "15:00",
                            endTime: "18:00",
                            realTimeInfo: "Ferry departs at 14:45, book tickets in advance"
                        ),
                        Place(
                            name: "Scoma's Restaurant",
                            address: "1965 Al Scoma Way, San Francisco, CA",
                            latitude: 37.8083,
                            longitude: -122.4180,
                            category: "restaurant",
                            description: "Waterfront seafood dining",
                            startTime: "19:00",
                            endTime: "21:00"
                        )
                    ],
                    notes: "Day 1: Explore iconic SF landmarks and waterfront"
                ),
                
                // Day 2: Downtown & Culture
                DayItinerary(
                    day: 2,
                    date: startDate.addingTimeInterval(86400),
                    places: [
                        Place(
                            name: "Union Square",
                            address: "333 Post St, San Francisco, CA",
                            latitude: 37.7880,
                            longitude: -122.4075,
                            category: "shopping",
                            description: "Central shopping and dining district",
                            startTime: "10:00",
                            endTime: "12:00"
                        ),
                        Place(
                            name: "Chinatown",
                            address: "Grant Ave & Bush St, San Francisco, CA",
                            latitude: 37.7941,
                            longitude: -122.4078,
                            category: "attraction",
                            description: "Oldest Chinatown in North America",
                            startTime: "12:30",
                            endTime: "14:00"
                        ),
                        Place(
                            name: "Z & Y Restaurant",
                            address: "655 Jackson St, San Francisco, CA",
                            latitude: 37.7957,
                            longitude: -122.4066,
                            category: "restaurant",
                            description: "Authentic Szechuan cuisine",
                            startTime: "14:15",
                            endTime: "15:30"
                        ),
                        Place(
                            name: "Lombard Street",
                            address: "Lombard St, San Francisco, CA",
                            latitude: 37.8021,
                            longitude: -122.4187,
                            category: "attraction",
                            description: "The most crooked street in the world",
                            startTime: "16:00",
                            endTime: "17:00"
                        ),
                        Place(
                            name: "Coit Tower",
                            address: "1 Telegraph Hill Blvd, San Francisco, CA",
                            latitude: 37.8024,
                            longitude: -122.4058,
                            category: "attraction",
                            description: "Art Deco tower with panoramic city views",
                            startTime: "17:30",
                            endTime: "19:00",
                            realTimeInfo: "Best sunset views from the top"
                        ),
                        Place(
                            name: "The House",
                            address: "1230 Grant Ave, San Francisco, CA",
                            latitude: 37.7989,
                            longitude: -122.4078,
                            category: "restaurant",
                            description: "Asian fusion in North Beach",
                            startTime: "19:30",
                            endTime: "21:00"
                        )
                    ],
                    notes: "Day 2: Downtown exploration and cultural districts"
                ),
                
                // Day 3: Nature & Parks
                DayItinerary(
                    day: 3,
                    date: startDate.addingTimeInterval(86400 * 2),
                    places: [
                        Place(
                            name: "Golden Gate Park",
                            address: "Golden Gate Park, San Francisco, CA",
                            latitude: 37.7694,
                            longitude: -122.4862,
                            category: "attraction",
                            description: "Large urban park with gardens and museums",
                            startTime: "09:00",
                            endTime: "11:30"
                        ),
                        Place(
                            name: "California Academy of Sciences",
                            address: "55 Music Concourse Dr, San Francisco, CA",
                            latitude: 37.7699,
                            longitude: -122.4661,
                            category: "attraction",
                            description: "Natural history museum with planetarium",
                            startTime: "12:00",
                            endTime: "15:00",
                            realTimeInfo: "Check out the living roof!"
                        ),
                        Place(
                            name: "Arsicault Bakery",
                            address: "397 Arguello Blvd, San Francisco, CA",
                            latitude: 37.7837,
                            longitude: -122.4588,
                            category: "restaurant",
                            description: "Award-winning croissants and pastries",
                            startTime: "15:30",
                            endTime: "16:00"
                        ),
                        Place(
                            name: "Palace of Fine Arts",
                            address: "3601 Lyon St, San Francisco, CA",
                            latitude: 37.8029,
                            longitude: -122.4484,
                            category: "attraction",
                            description: "Greco-Roman style landmark and lagoon",
                            startTime: "16:30",
                            endTime: "18:00",
                            realTimeInfo: "Beautiful for evening photography"
                        ),
                        Place(
                            name: "Gary Danko",
                            address: "800 North Point St, San Francisco, CA",
                            latitude: 37.8057,
                            longitude: -122.4205,
                            category: "restaurant",
                            description: "Michelin-starred fine dining",
                            startTime: "19:00",
                            endTime: "21:30",
                            realTimeInfo: "Reservations required - book ahead!"
                        )
                    ],
                    notes: "Day 3: Parks, museums, and fine dining finale"
                )
            ],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let tripId = try await firebaseService.createTrip(trip: sampleTrip)
            print("Trip created successfully, ID: \(tripId)")
            await loadTrips()
        } catch {
            errorMessage = "Failed to create trip: \(error.localizedDescription)"
        }
    }
    
    deinit {
        stopListening()
    }
}
