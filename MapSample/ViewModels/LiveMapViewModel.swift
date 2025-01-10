//
//  LiveMapViewModel.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import Foundation
import Combine
import MapKit

final class LiveMapViewModel: ObservableObject {
    
    let coordinator: LiveMapStateCoordinator
    
    weak var dataSource: LiveMapViewDataSource?
    weak var delegate: LiveMapViewDelegate?
    
    var metersPerPointAtAltitude: [CLLocationDistance: CGFloat] = [:]
    fileprivate var subscription: Set<AnyCancellable> = []
    
    init(coordinator: LiveMapStateCoordinator) {
        self.coordinator = coordinator
        
        coordinator.course
            .sink { [weak self] (course) in
                guard let strongSelf = self else { return }
                strongSelf.didLoadMap()
            }.store(in: &subscription)
        
        coordinator.selectedHoleId
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let strongSelf = self else { return }
            if let camera = strongSelf.getCamera() {
                strongSelf.delegate?.set(camera: camera, animated: false, lockCamera: false)
            }
        }.store(in: &subscription)
    }
    
    func getCamera() -> MKMapCamera? {
        guard let centroid = getCentroidOfHole(),
              let heading = getHeadingOfHole(),
              let distance = getDistanceOfHole(),
              let mapFrame = dataSource?.mapViewFrame() else { return nil }
        let initialCameraHeight = CameraCalculator.calculateCameraDistance(from: distance, with: 0)
        let mapInsets = UIEdgeInsets(top: 88 + SafeAreaInsetsKey.defaultValue.top,
                                     left: 0,
                                     bottom: 0,
                                     right: 0)
        guard let cgPointsPerMeter = metersPerPointAtAltitude.sorted(by: { $0.key < $1.key }).first(where: { $0.key > initialCameraHeight }) else {
            return MKMapCamera(lookingAtCenter: centroid,
                               fromDistance: initialCameraHeight,
                               pitch: 0,
                               heading: heading)
        }
        
        let visibleMapHeight = mapFrame.size.height - (mapInsets.top + mapInsets.bottom)
        let centerPointOfMap = CGPoint(x: mapFrame.size.width/2, y: mapFrame.size.height/2)
        let centerPointOfVisibleMap = CGPoint(x: mapFrame.size.width/2, y: visibleMapHeight/2)
        let offsetFromMapCenterToVisibleMapCenter = (centerPointOfVisibleMap.y + mapInsets.top) - centerPointOfMap.y
        
        let topWithoutInset = abs(mapInsets.top - SafeAreaInsetsKey.defaultValue.top)
        let bottomWithoutInset = abs(mapInsets.bottom - SafeAreaInsetsKey.defaultValue.bottom)
        let topPointsPreMeter = (topWithoutInset + 30) * cgPointsPerMeter.value
        let bottomPointsPreMeter = (bottomWithoutInset + 30) * cgPointsPerMeter.value
        let adjustedCameraHeight = CameraCalculator.calculateCameraDistance(from: distance, with: topPointsPreMeter + bottomPointsPreMeter)
        guard let adjustedCGPointsPerMeter = metersPerPointAtAltitude.sorted(by: { $0.key < $1.key }).first(where: { $0.key > adjustedCameraHeight }) else {
            return MKMapCamera(lookingAtCenter: centroid,
                               fromDistance: adjustedCameraHeight,
                               pitch: 0,
                               heading: heading)
        }
        let centerCoordinateWithOffset = SphericalUtil.destinationCoordinate(from: centroid,
                                                                             bearing: heading,
                                                                             distance: offsetFromMapCenterToVisibleMapCenter * adjustedCGPointsPerMeter.value)
        return MKMapCamera(lookingAtCenter: centerCoordinateWithOffset,
                           fromDistance: adjustedCameraHeight,
                           pitch: 0,
                           heading: heading)
    }
    
    func getCameraRegion() -> MKCoordinateRegion? {
        guard let centroid = getCentroidOfCourse() else { return nil }
        return MKCoordinateRegion(center: centroid,
                                  latitudinalMeters: 5000,
                                  longitudinalMeters: 5000)
    }
    
    func getDistanceOfHole() -> CLLocationDistance? {
        guard let selectedHoleData = coordinator.selectedHoleData else { return nil }
        return selectedHoleData.holeDistance
    }
    
    func getHeadingOfHole() -> CLLocationDirection? {
        guard let selectedHoleData = coordinator.selectedHoleData else { return nil }
        return selectedHoleData.heading
    }
    
    func getCentroidOfHole() -> CLLocationCoordinate2D? {
        guard let selectedHoleData = coordinator.selectedHoleData else { return nil }
        return selectedHoleData.centroid?.coordinate
    }
    
    func getCentroidOfCourse() -> CLLocationCoordinate2D? {
        guard let course = coordinator.course.value else { return nil }
        return course.location.coordinate
    }
    
    func didLoadMap() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let centroid = strongSelf.getCentroidOfCourse() else { return }
            if strongSelf.metersPerPointAtAltitude.isEmpty {
                for altitudeIndex in stride(from: 200, to: 5000, by: 50) {
                    let cameraDistance = CLLocationDistance(altitudeIndex)
                    let camera = MKMapCamera(lookingAtCenter: centroid,
                                             fromDistance: cameraDistance,
                                             pitch: 0,
                                             heading: 0)
                    strongSelf.delegate?.set(camera: camera, animated: false, lockCamera: false)
                    if let pointsPerMeter = strongSelf.dataSource?.distanceInMetersPrePoint(numberOfPoints: 100) {
                        strongSelf.metersPerPointAtAltitude[cameraDistance] = pointsPerMeter
                    }
                }
            }
            
            if let region = strongSelf.getCameraRegion() {
                strongSelf.delegate?.set(region: region, animated: false)
            }
            
            if let camera = strongSelf.getCamera() {
                strongSelf.delegate?.set(camera: camera, animated: true, lockCamera: false)
            }
        }
    }
    
}
