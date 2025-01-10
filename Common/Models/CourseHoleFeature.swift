//
//  CourseHoleFeature.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics
import MapKit

class CourseHoleFeature: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let featureId: Int
    let coordinates: [LocationWrapper]
    
    lazy var path: CGPath = {
        var tempPath = CGMutablePath()
        self.coordinates.forEach({ (coordinate) in
            if coordinate === self.coordinates.first {
                tempPath.move(to: coordinate.point)
            } else {
                tempPath.addLine(to: coordinate.point)
            }
        })
        
        tempPath.closeSubpath()
        return tempPath
        
    }()
    
    lazy var rect: MKMapRect = {
        var rect: MKMapRect = MKMapRect.null
        
        self.coordinates.forEach({ (coordinate) in
            let point = MKMapPoint(coordinate.coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 1, height: 1)
            rect = rect.union(pointRect)
        })
        return rect
    }()
    
    lazy var locations: [CLLocation] = {
        return self.coordinates.map({ $0.location })
    }()
    
    lazy var type: FeatureType = {
        return FeatureType(for: self.featureId)
    }()
    
    var isGreen: Bool {
        return type == .green;
    }
    
    var isTeeBox: Bool {
        return type == .teebox || type == .teeboxOld
    }
    
    var isFairway: Bool {
        return type == .fairway
    }
    
    var isFairwayCenter: Bool {
        return type == .fairwayCenter
    }
    
    var isSandTrap: Bool {
        return type == .greenSandtrap || type == .fairwaySandtrap
    }
    
    var isWaterHazard: Bool {
        return type == .greenWaterHazard || type == .fairwayWaterHazard
    }
    
    var isTree: Bool {
        return type == .trees
    }
    
    var isBoundingBox: Bool {
        return type == .boundingBox
    }
    
    var centerCoordinate: CLLocation? {
        
        guard coordinates.count > 0 else { return nil }
        
        var sumLat: Double = 0.0
        var sumLon: Double = 0.0
        
        coordinates.forEach { (coordinate) in
            sumLat = sumLat + Double(coordinate.coordinate.latitude)
            sumLon = sumLon + Double(coordinate.coordinate.longitude)
        }
        
        return CLLocation(latitude: sumLat / Double(coordinates.count), longitude: sumLon / Double(coordinates.count))
        
    }
    
    enum CodingKeys: String, CodingKey {
        case featureId
        case coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.featureId = try values.decode(Int.self, forKey: .featureId)
        let coordinates = try values.decode([CourseHoleCoordinate].self, forKey: .coordinates)
        self.coordinates = coordinates.map({ c in
            LocationWrapper(with: c.latitude, longitude: c.longitude)
        })
    }
    
    required init?(coder: NSCoder) {
        self.featureId = coder.decodeInteger(forKey: CodingKeys.featureId.rawValue)
        self.coordinates = coder.decodeArrayOfObjects(ofClass: LocationWrapper.self,forKey: CodingKeys.coordinates.rawValue) ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.featureId, forKey: CodingKeys.featureId.rawValue)
        coder.encode(self.coordinates, forKey: CodingKeys.coordinates.rawValue)
    }
    
    // MARK: Helpers
    
    func max(distanceFromFeatureTo location: CLLocation) -> Double {
        var maxDistance: Double = 0
        coordinates.forEach { (coordinate) in
            maxDistance = fmax(maxDistance, coordinate.location.distance(from: location))
        }
        return maxDistance
    }
    
    func min(distanceFromFeatureTo location: CLLocation) -> Double {
        var minDistance: Double = Double.greatestFiniteMagnitude
        coordinates.forEach { (coordinate) in
            minDistance = fmin(minDistance, coordinate.location.distance(from: location))
        }
        return minDistance
    }
    
    func contains(location: CLLocation) -> Bool {
        return contains(point: CGPoint(x: location.coordinate.longitude, y: location.coordinate.latitude))
    }
    
    func contains(point: CGPoint) -> Bool {
        return path.contains(point)
    }
    
    func closest(locationTo location: CLLocation) -> CLLocation? {
        var closestLocation: CLLocation? = nil
        
        coordinates.forEach { (coordinate) in
            if closestLocation == nil {
                closestLocation = coordinate.location
            } else {
                if location.distance(from: coordinate.location) < location.distance(from: closestLocation!) {
                    closestLocation = coordinate.location
                }
            }
        }
        
        return closestLocation
    }
}
