//
//  UserLocationManager.swift
//  Saavi
//
//  Created by gomad on 09/05/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class UserLocationManager: NSObject,CLLocationManagerDelegate {

    static let shared = UserLocationManager()
    let locationManager = CLLocationManager()
    
    var lattitude:Double = 0.00
    var longitude:Double = 0.00
    var lastTimestamp: Date?
    
    func getCurrentLocation(){
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.longitude = locValue.longitude
        self.lattitude = locValue.latitude
        
        if UserInfo.shared.isSalesRepUser! && AppFeatures.shared.isSlaesRepLocationEnabled{
            let now = Date()
            let interval = TimeInterval((lastTimestamp != nil) ? now.timeIntervalSince(lastTimestamp!) : 0.0)
            
            if !(lastTimestamp != nil) || interval >= 15 * 60 {
                lastTimestamp = now
                self.callSaveLocationAPI()
            }
        }
    }
    
    private func callSaveLocationAPI(){
       
        let URLstring = SyncEngine.baseURL+SyncEngine.SaveLocation
        let dict = ["UserID": UserInfo.shared.userId!,"Latitude": "\(self.lattitude)","Longitude": "\(self.longitude)"] as [String : Any]
        SyncEngine.sharedInstance.sendPostRequestToServer(dictionary: dict, strURL: URLstring) { (response) in

            debugPrint(response)
        }
    }
}

