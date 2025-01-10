//
//  SphericalUtil.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import MapKit

final class SphericalUtil {
    
    /**
     Calculates a new coordinate given a start coordinate, bearing, and distance.

     - Parameters:
        - start: The starting coordinate.
        - bearing: The bearing in degrees from the start coordinate.
        - distance: The distance in meters from the start coordinate.

     - Returns: A new `CLLocationCoordinate2D` that represents the destination coordinate.
     */
    static func destinationCoordinate(from start: CLLocationCoordinate2D, bearing: CLLocationDegrees, distance: CLLocationDistance) -> CLLocationCoordinate2D {
        let radiusOfEarth = 6378100.0 // Radius of the Earth in meters
        let bearingRadians = bearing * .pi / 180.0 // Convert bearing to radians
        let latitudeRadians = start.latitude * .pi / 180.0 // Convert latitude to radians
        let longitudeRadians = start.longitude * .pi / 180.0 // Convert longitude to radians

        let distanceOverRadius = distance / radiusOfEarth // Distance over the Earth's radius

        let newLatitudeRadians = asin(sin(latitudeRadians) * cos(distanceOverRadius) +
                                      cos(latitudeRadians) * sin(distanceOverRadius) * cos(bearingRadians))
        let newLongitudeRadians = longitudeRadians + atan2(sin(bearingRadians) * sin(distanceOverRadius) * cos(latitudeRadians),
                                                           cos(distanceOverRadius) - sin(latitudeRadians) * sin(newLatitudeRadians))

        // Convert back to degrees
        let newLatitude = newLatitudeRadians * 180.0 / .pi
        let newLongitude = newLongitudeRadians * 180.0 / .pi

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
}
