//
//  Utils.swift
//  GeckoDrivelog
//
//  Created by Nils Kleinert on 25.12.18.
//  Copyright © 2018 Nils Kleinert. All rights reserved.
//

import Foundation
import CoreLocation

class Utils {
    
    static var driveName: String = "Unbekannt"
    static var isDriving: Bool = false
    static var drivenMeters: Double = 0.0
    static var locations: [CLLocationCoordinate2D] = []
    static var locationManager = CLLocationManager()
    
}
