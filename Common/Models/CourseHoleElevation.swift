//
//  CourseHoleElevation.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation
import CoreLocation

class CourseHoleElevation: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let latitude: Double
    let longitude: Double
    let elevation: Double
    
    lazy var location: CLLocation = {
        return CLLocation(latitude: CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
    }()
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case elevation
    }
    
    init(latitude: Double, longitude: Double, elevation: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
    
    required init?(coder: NSCoder) {
        self.latitude = coder.decodeDouble(forKey: CodingKeys.latitude.rawValue)
        self.longitude = coder.decodeDouble(forKey: CodingKeys.longitude.rawValue)
        self.elevation = coder.decodeDouble(forKey: CodingKeys.elevation.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.latitude, forKey: CodingKeys.latitude.rawValue)
        coder.encode(self.longitude, forKey: CodingKeys.longitude.rawValue)
        coder.encode(self.elevation, forKey: CodingKeys.elevation.rawValue)
    }
}
