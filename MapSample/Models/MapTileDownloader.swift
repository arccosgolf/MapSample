//
//  MapTileDownloader.swift
//  MapSample
//
//  Created by Greg Silesky on 1/20/25.
//

import Foundation
import MapKit

struct SnapshotAspectRatio {
    let width: CGFloat
    let height: CGFloat
}

actor MapTileDownloader {
    enum ErrorType: Error {
        case insufficientHoleData
    }
    
    private let course: Course
    
    init(course: Course) {
        self.course = course
    }
    
    func downloadSnapshots() async throws {
        let aspectRatio = SnapshotAspectRatio(width: 9, height: 16.0)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for hole in course.holes {
                guard let centroid = hole.centroid, let heading = hole.heading else {
                    throw ErrorType.insufficientHoleData
                }

                let distance = hole.holeDistance
                let cameraDistance = CameraCalculator.calculateCameraDistance(from: distance, with: 0)
                group.addTask { [weak self] in
                    try await self?.mapSnapshot(center: centroid.location, cameraDistance: cameraDistance, heading: heading, size: MapTileDownloader.highQualityImageSize(for: aspectRatio))
                }
            }
            try await group.waitForAll()
        }
    }

    private func mapSnapshot(center: CLLocation,
                             cameraDistance: CLLocationDistance,
                             heading: CLLocationDirection,
                             size: CGSize) async throws {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        mapSnapshotOptions.camera = MKMapCamera(lookingAtCenter: center.coordinate,
                                                fromDistance: cameraDistance,
                                                pitch: 0,
                                                heading: heading)
        mapSnapshotOptions.mapType = .satellite
        mapSnapshotOptions.size = size
        mapSnapshotOptions.scale = await UIScreen.main.scale
        let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
        try await snapshotter.start()
    }
    
    @MainActor static func highQualityImageSize(for aspectRatio: SnapshotAspectRatio,
                                     padding: UIOffset = UIOffset(horizontal: 0, vertical: 0)) -> CGSize {
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width - padding.horizontal
        let screenHeight = screenBounds.height - padding.vertical
        
        let screenAspectRatio = screenWidth / screenHeight
        let targetAspectRatio = aspectRatio.width / aspectRatio.height
        
        var width: CGFloat
        var height: CGFloat
        
        if targetAspectRatio > screenAspectRatio {
            // Aspect ratio is wider than the screen's aspect ratio
            width = screenWidth
            height = width / targetAspectRatio
        } else {
            // Aspect ratio is taller than or equal to the screen's aspect ratio
            height = screenHeight
            width = height * targetAspectRatio
        }
        
        return CGSize(width: width, height: height)
    }
}
