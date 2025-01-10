//
//  CameraCalculator.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation
import MapKit

final class CameraCalculator {
    
    static func calculateCameraDistance(from distance: CLLocationDistance, with padding: CLLocationDistance) -> CLLocationDistance  {
        let margin: Double = distance * 0.2

        let longDimentionWithMargin = distance + padding + margin
        let FOV: Double = 30.0 // Field of view in degrees
        let FOVRadians = FOV * .pi / 180.0 // Convert to radians
        return max(200, ((longDimentionWithMargin/2) / tan(FOVRadians / 2)))
    }
}
