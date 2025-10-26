# TravelVerse

An iOS travel planning app with itinerary management, photo uploads, and sentiment tracking. Built for a hackathon project.

## Features

### ✈️ Core Features
- **Trip Itinerary Display**
  - View travel itineraries generated via web scraping
  - Real-time location info and recommendations
  - Day-by-day detailed planning

- **Photo Upload with Location Tracking**
  - Upload photos during travel
  - Automatic GPS location recording
  - Photo-to-place association
  - Camera and album support

- **Sentiment Tagging**
  - Tag photos with emotions (Happy, Excited, Peaceful, etc.)
  - Multiple sentiment selection
  - Custom emotion input

- **Data Sharing**
  - Photos and location stored in Firestore
  - Accessible via web portal for team members
  - Used for travel video generation

## Project Structure

```
TravelVerse/
├── Models/
│   ├── Trip.swift
│   ├── Photo.swift
│   └── User.swift
├── ViewModels/
│   ├── TripViewModel.swift
│   └── PhotoViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── ItineraryView.swift
│   └── UploadPhotoView.swift
├── Services/
│   ├── FirebaseService.swift
│   └── LocationService.swift
└── TravelVerseApp.swift
```

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Backend**: Firebase (Firestore)
- **Architecture**: MVVM
- **Location**: CoreLocation

## Firestore Data Structure

**Trip Collection** (`trips/{tripId}`):
```json
{
  "userId": "string",
  "cityName": "string",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "itinerary": [
    {
      "day": 1,
      "date": "timestamp",
      "places": [
        {
          "name": "string",
          "address": "string",
          "latitude": "double",
          "longitude": "double",
          "category": "string",
          "description": "string",
          "startTime": "string",
          "endTime": "string",
          "realTimeInfo": "string"  //web scraping data
        }
      ],
      "notes": "string"
    }
  ],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Photo Collection** (`photos/{photoId}`):
```json
{
  "userId": "string",
  "tripId": "string",
  "placeId": "string",
  "placeName": "string",
  "imageUrl": "string",  // Firebase Storage URL
  "caption": "string",
  "sentiment": ["string"],  // Emotion tags
  "latitude": "double",
  "longitude": "double",
  "timestamp": "timestamp",
  "cityName": "string"
}
```

## Team Integration

### For Web Scraping Team:
- Write itinerary data to Firestore `trips` collection
- Update `realTimeInfo` field with live information

### For Web Portal Team:
- Read `photos` collection from Firestore
- Use `latitude` and `longitude` to display photos on map
- Generate timeline based on `timestamp`
- Download photos via `imageUrl` for video generation

## Future Improvements

- User authentication with Firebase Auth
- Offline support with Firestore persistence
- Map view with route display
- Social media sharing
- Push notifications for itinerary updates
- Multi-language support

## License

Hackathon demo project.
