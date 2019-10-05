//
//  LocationService.swift
//  Points
//
//  Created by Denis Bogatyrev on 24/09/2019.
//  Copyright © 2019 Denis Bogatyrev. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceType: class {
    var currentLocation: CLLocation? { get }
    func addObserver(_ observer: LocationServiceObserverType)
}

protocol LocationServiceObserverType: class {
    func didUpdateCurrentLocations(_ location: CLLocation)
}

class LocationService: NSObject, LocationServiceType {
    var currentLocation: CLLocation?
    
//    private let LocationLongitudeKey = "LocationLatitudeKey"
//    private let LocationLatitudeKey = "LocationLatitudeKey"
    
    private let locationManager = CLLocationManager()
    private var observers: [LocationServiceObserverType] = []
    
    func addObserver(_ observer: LocationServiceObserverType) {
        observers.append(observer)
        requesPermissions()
    }
    
    private func requesPermissions() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        guard let location = manager.location ?? locations.last else { return }
        currentLocation = location
        observers.forEach {
            $0.didUpdateCurrentLocations(location)
        }
    }
}
