//
//  LocationService.swift
//  TravelVerse
//
//  Created by Bingbing Ma on 10/25/25.
//

import Foundation
import CoreLocation
import Combine

/// 位置服务，管理GPS定位
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentCityName: String?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// 请求位置权限
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 开始获取位置
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    /// 停止获取位置
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 获取当前位置（一次性）
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    /// 反向地理编码：从GPS坐标获取城市名称
    func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                // 尝试获取城市名称，优先使用locality（城市），其次是administrativeArea（州/省）
                let city = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                DispatchQueue.main.async {
                    self.currentCityName = city
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        // 自动进行反向地理编码获取城市名称
        reverseGeocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
