//
//  LocationManager.swift
//  PlaceLookupDemo
//
//  Created by Jeremy Taylor on 1/19/23.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManger = CLLocationManager()
    
    override init() {
        super.init()
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.distanceFilter = kCLDistanceFilterNone
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation() // Remember to update Info.plist!
        locationManger.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
}
