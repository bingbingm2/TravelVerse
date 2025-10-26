//
//  ItineraryView.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import SwiftUI
import MapKit

/// 行程详情视图 - 显示旅行的详细行程
struct ItineraryView: View {
    let trip: Trip
    @State private var selectedDay: Int = 1
    @State private var showingUploadPhoto = false
    @State private var selectedPlace: Place?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 旅行信息头部
                tripHeaderView
                
                // 天数选择器
                daySelector
                
                // 当天行程
                if let dayItinerary = trip.itinerary.first(where: { $0.day == selectedDay }) {
                    dayItineraryView(dayItinerary)
                }
            }
            .padding()
        }
        .navigationTitle(trip.cityName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: UploadPhotoView(trip: trip)) {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                }
            }
        }
    }
    
    // MARK: - 旅行信息头部
    private var tripHeaderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(dateRangeString)
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("\(trip.itinerary.count) Days")
                    .font(.subheadline)
            }
            
            Divider()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 天数选择器
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(trip.itinerary) { day in
                    DayButton(
                        day: day.day,
                        isSelected: selectedDay == day.day
                    ) {
                        selectedDay = day.day
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - 每天的行程
    private func dayItineraryView(_ dayItinerary: DayItinerary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 日期标题
            HStack {
                Text("Day \(dayItinerary.day)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(formatDate(dayItinerary.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 备注
            if let notes = dayItinerary.notes {
                Text(notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            // 地点列表
            VStack(spacing: 12) {
                ForEach(Array(dayItinerary.places.enumerated()), id: \.element.id) { index, place in
                    PlaceCard(
                        place: place,
                        index: index + 1,
                        trip: trip,
                        day: dayItinerary.day
                    )
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let start = formatter.string(from: trip.startDate)
        let end = formatter.string(from: trip.endDate)
        return "\(start) - \(end)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, EEEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

// MARK: - 天数按钮
struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Day")
                    .font(.caption2)
                Text("\(day)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(width: 60, height: 60)
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.blue : Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 5)
        }
    }
}

// MARK: - 地点卡片
struct PlaceCard: View {
    let place: Place
    let index: Int
    let trip: Trip
    let day: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 索引圆圈
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 地点信息
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(place.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // 上传照片按钮
                    NavigationLink(destination: UploadPhotoView(
                        trip: trip,
                        day: day,
                        place: place
                    )) {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    
                    if let startTime = place.startTime {
                        Text(startTime)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(place.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let description = place.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 实时信息（队友的web scraping数据）
                if let realTimeInfo = place.realTimeInfo {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text(realTimeInfo)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 分类标签
                Text(categoryName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var categoryName: String {
        switch place.category {
        case "restaurant": return "Restaurant"
        case "attraction": return "Attraction"
        case "hotel": return "Hotel"
        case "shopping": return "Shopping"
        default: return "Other"
        }
    }
    
    private var categoryColor: Color {
        switch place.category {
        case "restaurant": return .orange
        case "attraction": return .blue
        case "hotel": return .purple
        case "shopping": return .pink
        default: return .gray
        }
    }
}

#Preview {
    NavigationView {
        ItineraryView(trip: Trip(
            userId: "demo",
            cityName: "San Francisco",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            itinerary: [
                DayItinerary(
                    day: 1,
                    date: Date(),
                    places: [
                        Place(
                            name: "Palace of the Fine Arts",
                            address: "3601 Lyon St, San Francisco, CA 94123",
                            latitude: 37.8029,
                            longitude: 122.4484,
                            category: "attraction",
                            description: "a historic Greco-Roman style landmark in San Francisco, built for the 1915 Panama-Pacific International Exposition",
                            startTime: "10:00",
                            endTime: "17:00",
                            realTimeInfo: "Today's sunny, many visitors."
                        )
                    ],
                    notes: "First Day of Itinerary"
                )
            ],
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
