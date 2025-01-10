//
//  LiveMapViewDataSource.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation

protocol LiveMapViewDataSource: AnyObject {
    func mapViewFrame() -> CGRect
    func distanceInMetersPrePoint(numberOfPoints: CGFloat) -> CGFloat
}
