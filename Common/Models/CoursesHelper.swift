//
//  CoursesHelper.swift
//
//  Created by Greg Silesky on 6/19/23.
//

import Foundation
import CoreLocation

class CoursesHelper {
    
    static func headingBetweenLocations(_ s1: CLLocation, and s2: CLLocation) -> CLLocationDirection {
        return CoursesHelper.headingBetweenCoordinates(s1.coordinate, and: s2.coordinate)
    }
    
    static func headingBetweenCoordinates(_ s1: CLLocationCoordinate2D, and s2: CLLocationCoordinate2D) -> CLLocationDirection {
        
        let lat1 = s1.latitude * .pi / 180.0
        let lat2 = s2.latitude * .pi / 180.0
        let dLon = (s2.longitude - s1.longitude) * .pi / 180.0

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let brng = atan2(y, x)
        var degrees = brng * 180.0 / .pi
        if degrees < 0 {
            degrees = 360 - abs(degrees)
        }
        return degrees
    }
    
    static func midpointBetween(_ start: CLLocation, and end: CLLocation) -> CLLocation {
        let latitude = (start.coordinate.latitude + end.coordinate.latitude)/2
        let longitude = (start.coordinate.longitude + end.coordinate.longitude)/2
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
