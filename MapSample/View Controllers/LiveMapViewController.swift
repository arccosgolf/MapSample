//
//  LiveMapViewController.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import UIKit
import MapKit

class LiveMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureMapView()
    }
    
    func configureMapView() {
        self.mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 200, maxCenterCoordinateDistance: 10000), animated: true)
        self.mapView.mapType = .satellite
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = false
    }
}

//*****************************************************************************/
// MARK: - MapView Delegate
//*****************************************************************************/
extension LiveMapViewController : MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("Did finish rendering all visible tiles. Fully rendered: \(fullyRendered)")
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: any Error) {
        print("Did fail loading map with error. Error: \(error.localizedDescription)")
    }
}

//*****************************************************************************/
// MARK: - Live Map Data Source
//*****************************************************************************/
extension LiveMapViewController : LiveMapViewDataSource {
    
    func mapViewFrame() -> CGRect {
        return mapView.frame
    }
    
    func distanceInMetersPrePoint(numberOfPoints: CGFloat) -> CGFloat {
        let upperLeft = mapView.convert(CGPoint(x: mapView.frame.minX, y: mapView.frame.minY), toCoordinateFrom: mapView)
        let lowerLeft = mapView.convert(CGPoint(x: mapView.frame.minX, y: mapView.frame.minY + numberOfPoints), toCoordinateFrom: mapView)
        let upperLeftLocation = CLLocation(latitude: upperLeft.latitude, longitude: upperLeft.longitude)
        let lowerLeftLocation = CLLocation(latitude: lowerLeft.latitude, longitude: lowerLeft.longitude)
        let distance = upperLeftLocation.distance(from: lowerLeftLocation)
        return distance/numberOfPoints
    }

}

//*****************************************************************************/
// MARK: - Live Map Delegate
//*****************************************************************************/
extension LiveMapViewController : LiveMapViewDelegate {
    
    func set(region: MKCoordinateRegion, animated: Bool) {
        mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        self.mapView.setRegion(region, animated: animated)
    }
    
    func set(camera: MKMapCamera, animated: Bool, lockCamera: Bool) {
        mapView.setCamera(camera, animated: animated)
        mapView.isZoomEnabled = !lockCamera
        mapView.isRotateEnabled = !lockCamera
        mapView.isPitchEnabled = !lockCamera
        mapView.isScrollEnabled = !lockCamera
    }
}
