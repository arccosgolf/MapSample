//
//  LiveMapViewDelegate.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation
import MapKit

protocol LiveMapViewDelegate: AnyObject {
    func set(region: MKCoordinateRegion, animated: Bool)
    func set(camera: MKMapCamera, animated: Bool, lockCamera: Bool)
}
