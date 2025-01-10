//
//  LocationWrapper.swift
//
//  Created by Konrad Winkowski on 4/20/18.
//  Copyright © 2018 Arccos Golf LLC. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationWrapper: NSObject, NSSecureCoding, Codable {
    static var supportsSecureCoding: Bool = true
    

    private(set) var coordinate: CLLocationCoordinate2D
    
    lazy var location: CLLocation = {
        return CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }()
    
    lazy var point: CGPoint = {
        return CGPoint(x: self.coordinate.longitude, y: self.coordinate.latitude)
    }()
    
    init(with latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Setter
    func setCoordinate(from coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try values.decode(Double.self, forKey: .latitude)
        let lon = try values.decode(Double.self, forKey: .longitude)
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coordinate.latitude, forKey: .latitude)
        try container.encode(self.coordinate.longitude, forKey: .longitude)
    }
    
    // MARK: NSCoding
    
    init?(coder aDecoder: NSCoder) {
        
        let lat = aDecoder.decodeDouble(forKey: "latitude")
        let lon = aDecoder.decodeDouble(forKey: "longitude")
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        super.init()
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.coordinate.latitude, forKey: "latitude")
        aCoder.encode(self.coordinate.longitude, forKey: "longitude")
    }
    
}
