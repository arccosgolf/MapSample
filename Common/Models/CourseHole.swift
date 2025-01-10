//
//  CourseHole.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation
import MapKit

class CourseHole: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let mensPar: Int
    let womensPar: Int
    let mensHandicap: Float
    let womensHandicap: Float
    let holeId: Int
    let courseId: Int
    let courseVersion: Int
    let holeTees: [CourseHoleTee]
    let features: [CourseHoleFeature]
    let elevations: [CourseHoleElevation]
    
    private let visableAngleConstant: Double = (1/(2 * tan(0.261799)))
    private let syncQueue: DispatchQueue = DispatchQueue(label: "sync_queue")
    
    lazy var heading: CLLocationDirection? = {
        guard let furthestTeeLocation = self.furthestTeeLocation, let greenCenter = self.greenCenter else { return nil }
        return CoursesHelper.headingBetweenLocations(furthestTeeLocation, and: greenCenter)
    }()
    
    lazy var holeFeatures: [CourseHoleFeature] = {
       return self.features.map({ $0 })
    }()
    
    lazy var green: CourseHoleFeature? = {
        return self.features.first(where: { (feature) -> Bool in
            return feature.isGreen
        })
    }()
    
    lazy var sandtrapFeatures: [CourseHoleFeature] = {
        var temp: [CourseHoleFeature] = []
        self.features.forEach({ (feature) in
            guard feature.isSandTrap else { return }
            temp.append(feature)
        })
        return temp
    }()
    
    lazy var greenFeatures: [CourseHoleFeature] = {
        var temp: [CourseHoleFeature] = []
        self.features.forEach({ (feature) in
            guard feature.isGreen else { return }
            temp.append(feature)
        })
        return temp
    }()
    
    lazy var teeFeatures: [CourseHoleFeature] = {
        var temp: [CourseHoleFeature] = []
        self.features.forEach({ (feature) in
            guard feature.isTeeBox else { return }
            temp.append(feature)
        })
        return temp
    }()
    
    lazy var fairwayFeatures: [CourseHoleFeature] = {
        var temp: [CourseHoleFeature] = []
        self.features.forEach({ (feature) in
            guard feature.isFairway else { return }
            temp.append(feature)
        })
        return temp
    }()
    
    lazy var fairwayCenterFeatures: [CourseHoleFeature] = {
        var temp: [CourseHoleFeature] = []
        self.features.forEach({ (feature) in
            guard feature.isFairwayCenter else { return }
            temp.append(feature)
        })
        return temp
    }()
    
    lazy var furthestFairwayCenterLocation: CLLocation? = {
        var furthest: CLLocation? = nil
        guard let furthestTee = self.furthestTeeLocation else { return furthest }
        for fariwayFeature in self.fairwayFeatures {
            for fariwayLocation in fariwayFeature.coordinates {
                if furthest == nil {
                    furthest = fariwayLocation.location
                } else if let f = furthest {
                    if fariwayLocation.location.distance(from: furthestTee) > f.distance(from: furthestTee) {
                        furthest = fariwayLocation.location
                    }
                }
            }
        }
        return furthest
    }()
    
    lazy var furthestTeeLocation: CLLocation? = {
        var furthest: CLLocation? = nil
        guard let greenCenter = self.greenCenter else { return furthest }
        for teeFeature in self.teeFeatures {
            for teeLocation in teeFeature.coordinates {
                if furthest == nil {
                    furthest = teeLocation.location
                } else {
                    if teeLocation.location.distance(from: greenCenter) > furthest!.distance(from: greenCenter) {
                        furthest = teeLocation.location
                    }
                }
            }
        }
        return furthest
    }()
    
    lazy var furthestTeeCenter: CLLocation? = {
        
        guard var furthest = self.teeCenters.first,
              let greenCenter = self.greenCenter else { return nil }
        
        for teeCenter in self.teeCenters {
            if greenCenter.distance(from: teeCenter) > greenCenter.distance(from: furthest) {
                furthest = teeCenter
            }
        }
        
        return furthest
    }()
    
    lazy var greenCenter: CLLocation? = {
        var latitudeSumGreen: Double = 0.0
        var longitudeSumGreen: Double = 0.0
        var greenPoints: Int = 0
        
        self.features.forEach {
            guard $0.isGreen else { return }
            
            $0.coordinates.forEach {
                latitudeSumGreen = latitudeSumGreen + Double($0.coordinate.latitude)
                longitudeSumGreen = longitudeSumGreen + Double($0.coordinate.longitude)
                greenPoints = greenPoints + 1
            }
            
        }
        
        guard greenPoints > 0 else { return nil }
        
        return CLLocation(latitude: latitudeSumGreen / Double(greenPoints), longitude: longitudeSumGreen / Double(greenPoints))
    }()
    
    lazy var closestGreenLocation: CLLocation? = {
        var closest: CLLocation? = nil
        guard let furthestCenter = self.furthestFairwayCenterLocation ?? self.furthestTeeLocation else { return closest }
        for greenFeature in self.greenFeatures {
            for greenLocation in greenFeature.coordinates {
                if closest == nil {
                    closest = greenLocation.location
                } else if let c = closest {
                    if greenLocation.location.distance(from: furthestCenter) < c.distance(from: furthestCenter) {
                        closest = greenLocation.location
                    }
                }
            }
        }
        return closest
    }()
    
    lazy var furthestGreenLocation: CLLocation? = {
        var furthest: CLLocation? = nil
        guard let furthestCenter = self.furthestFairwayCenterLocation ?? self.furthestTeeLocation else { return furthest }
        for greenFeature in self.greenFeatures {
            for greenLocation in greenFeature.coordinates {
                if furthest == nil {
                    furthest = greenLocation.location
                } else if let f = furthest {
                    if greenLocation.location.distance(from: furthestCenter) > f.distance(from: furthestCenter) {
                        furthest = greenLocation.location
                    }
                }
            }
        }
        return furthest
    }()
    
    lazy var teeCenters: [CLLocation] = {
        var temp: [CLLocation] = []
        
        for teeBox in self.teeFeatures {
            var latitudeSumTee: Double = 0.0
            var longitudeSumTee: Double = 0.0
            
            for featureLocation in teeBox.coordinates {
                latitudeSumTee = latitudeSumTee + Double(featureLocation.coordinate.latitude)
                longitudeSumTee = longitudeSumTee + Double(featureLocation.coordinate.longitude)
            }
            
            guard teeBox.coordinates.count > 0 else { continue }
            
            temp.append(CLLocation(latitude: latitudeSumTee / Double(teeBox.coordinates.count), longitude: longitudeSumTee / Double(teeBox.coordinates.count)))
            
        }
        
        return temp
    }()
    
    
    lazy var featurePointsExcludingWater: [LocationWrapper] = {
        var temp: [LocationWrapper] = []
        self.features.forEach({ (feature) in
            
            if feature.isWaterHazard { return }
            
            for featureLocaiton in feature.coordinates {
                temp.append(featureLocaiton)
            }
        })
        return temp
    }()
    
    lazy var tees: [CourseHoleTee] = {
       return self.holeTees.compactMap({ $0 })
    }()
    
    lazy var holeDistance: CLLocationDistance? = {
        guard let furthestTeeLocation = furthestTeeLocation, let closestGreenFromFairwayCenter = closestGreenLocation, let furthestGreenFromFairwayCenter = furthestGreenLocation else { return nil }
        if let furthestFairwayCenterFromTee = furthestFairwayCenterLocation {
            let teeToCenterDistacne = furthestTeeLocation.distance(from: furthestFairwayCenterFromTee)
            let centerToGreenDistacne = furthestFairwayCenterFromTee.distance(from: furthestGreenFromFairwayCenter)
            return teeToCenterDistacne + centerToGreenDistacne
        } else {
            return furthestTeeLocation.distance(from: furthestGreenFromFairwayCenter)
        }
    }()
    
    lazy var greenDistance: CLLocationDistance? = {
        guard let furthestTeeLocation = furthestTeeLocation, let closestGreenFromFairwayCenter = closestGreenLocation, let furthestGreenFromFairwayCenter = furthestGreenLocation else { return nil }
        if let furthestFairwayCenterFromTee = furthestFairwayCenterLocation {
            let centerToGreenClosestDistacne = furthestFairwayCenterFromTee.distance(from: closestGreenFromFairwayCenter)
            let centerToGreenFurtherstDistacne = furthestFairwayCenterFromTee.distance(from: furthestGreenFromFairwayCenter)
            return centerToGreenFurtherstDistacne - centerToGreenClosestDistacne
        } else {
            let teeToGreenClosestDistacne = furthestTeeLocation.distance(from: closestGreenFromFairwayCenter)
            let teeToGreenFurtherstDistacne = furthestTeeLocation.distance(from: furthestGreenFromFairwayCenter)
            return teeToGreenFurtherstDistacne - teeToGreenClosestDistacne
        }
    }()
    
    lazy var rectanglePath: CGPath = {
        var tempPath = CGMutablePath()
        self.cornersOfBoundingRectangle.forEach({ (coordinate) in
            if coordinate === self.cornersOfBoundingRectangle.first {
                tempPath.move(to: coordinate.point)
            } else {
                tempPath.addLine(to: coordinate.point)
            }
        })
        
        tempPath.closeSubpath()
        return tempPath
        
    }()
    
    lazy var centroid: LocationWrapper? = {
       
        let polygonPoints = self.cornersOfBoundingRectangle
        
        // The geometric centroid of a polygon is the mean value on each axis for all of its vertices.
        if polygonPoints.count == 0 {
            return nil
        }
        
        var sumOnLatitude: Double = 0.0
        var sumOnLongitude: Double = 0.0
        
        for vertex in polygonPoints {
            sumOnLatitude = sumOnLatitude + vertex.coordinate.latitude
            sumOnLongitude = sumOnLongitude + vertex.coordinate.longitude
        }
    
        return LocationWrapper(with: sumOnLatitude / Double(polygonPoints.count), longitude: sumOnLongitude / Double(polygonPoints.count))
        
    }()
    
    lazy var cornersOfBoundingRectangle: [LocationWrapper] = {
       
            // We need to find the centroid to the bounding rect alongside the heading.
            // First we need to find the line defined by two points: green and tee, and then span feature points looking for the one with the most
            // distance to that line, in both directions.
            // Then, find the perpendicular to that line and swipe again to find the bounding points on the other dimention.
            
            //////////////////////////////////////////////////////////////////////////////////////////
            // 1. find line between tee box and green. A line is defined by the equation ax + by + c = 0. The equation of a line passing by two points P1(x1,y1) and P2(x2,y2) is:
            // (y - y1) = m(x-x1) where: m is the slope and is found using the following: m = (y2 - y1)/(x2 - x1). Rearranging all that result in:
            // a = m
            // b = -1
            // c = -mx1 + y1
        
        var temp: [LocationWrapper] = []
        
        guard let teeBoxLocation = self.furthestTeeLocation,
            let greenLocation = self.greenCenter else {
            return temp
        }
        var slope : Double
        
        if (greenLocation.coordinate.latitude == teeBoxLocation.coordinate.latitude)  {
            slope = (greenLocation.coordinate.latitude - (teeBoxLocation.coordinate.latitude - 0.0000000000001)) / (greenLocation.coordinate.longitude - teeBoxLocation.coordinate.longitude)
        } else if((greenLocation.coordinate.longitude == teeBoxLocation.coordinate.longitude)) {
            slope = (greenLocation.coordinate.latitude - teeBoxLocation.coordinate.latitude ) / (greenLocation.coordinate.longitude - (teeBoxLocation.coordinate.longitude - 0.00000000000001))
        } else {
            slope = (greenLocation.coordinate.latitude - teeBoxLocation.coordinate.latitude) / (greenLocation.coordinate.longitude - teeBoxLocation.coordinate.longitude)
        }
        
        let a: Double = slope
        let b: Double = -1
        let c: Double = (-1 * slope * teeBoxLocation.coordinate.longitude) + teeBoxLocation.coordinate.latitude
        
        let line = GeometricLine(a: a, b: b, c: c)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // 2. We will maintain two points, each one is on a half-plane defined by the line. Considering b=-1 as assumed before, then the line's equation can be re-written as follows:
        // y = ax + c. For each point examined if it invalidates the inequality y < ax + c then it belongs to the other half, otherwise it is on the original half.
        // right and left directions are assumed inorder to facilitate the comprehension of the algorithm.
        
        let featurePointsExcludingWater = self.featurePointsExcludingWater
        var rightmostBoundingPointLocation: LocationWrapper?
        var leftmostBoundingPointLocation: LocationWrapper?
        
        for featureLocation in featurePointsExcludingWater {
            if self.point(featurePoint: featureLocation, isRightTo: line) {
                if rightmostBoundingPointLocation == nil {
                    rightmostBoundingPointLocation = LocationWrapper(with: featureLocation.coordinate.latitude, longitude: featureLocation.coordinate.longitude)
                } else {
                    let distanceOfCurrentRightmostPoint: Double = self.distanceFrom(point: rightmostBoundingPointLocation!, to: line)
                    let distanceOfNewRightPoint: Double = self.distanceFrom(point: featureLocation, to: line)
                    if distanceOfNewRightPoint > distanceOfCurrentRightmostPoint {
                        rightmostBoundingPointLocation?.setCoordinate(from: featureLocation.coordinate)
                    }
                }
            } else if self.point(featurePoint: featureLocation, isLeftTo: line) {
                if leftmostBoundingPointLocation == nil {
                    leftmostBoundingPointLocation = LocationWrapper(with: featureLocation.coordinate.latitude, longitude: featureLocation.coordinate.longitude)
                } else {
                    let distanceOfCurrentLeftmostPoint: Double = self.distanceFrom(point: leftmostBoundingPointLocation!, to: line)
                    let distanceOfNewLeftPoint: Double = self.distanceFrom(point: featureLocation, to: line)
                    if distanceOfNewLeftPoint > distanceOfCurrentLeftmostPoint {
                        leftmostBoundingPointLocation?.setCoordinate(from: featureLocation.coordinate)
                    }
                }
            } else {
                // point is contained in line
                continue
            }
        }
        
        /////////////////////////////////////////////////////////////////////////////////////////
        // 3. find topmost and bottommost points:
        
        let midLocationBetweenTeeAndGreen: CLLocation = CoursesHelper.midpointBetween(teeBoxLocation, and: greenLocation)
        let perpendicularA: Double = -1 * (1/line.a)
        let perpendicularB: Double = -1
        let perpendicularC: Double = midLocationBetweenTeeAndGreen.coordinate.latitude - (perpendicularA * midLocationBetweenTeeAndGreen.coordinate.longitude)
        
        let perpendicularLine = GeometricLine(a: perpendicularA, b: perpendicularB, c: perpendicularC)
        
        var topmostBoundingPointLocation: LocationWrapper?
        var bottommostBoundingPointLocation: LocationWrapper?
        
        for featureLocation in featurePointsExcludingWater {
            if self.point(featurePoint: featureLocation, isRightTo: perpendicularLine) {
                if topmostBoundingPointLocation == nil {
                    topmostBoundingPointLocation = LocationWrapper(with: featureLocation.coordinate.latitude, longitude: featureLocation.coordinate.longitude)
                } else {
                    let distanceOfCurrentTopmostPoint: Double = self.distanceFrom(point: topmostBoundingPointLocation!, to: perpendicularLine)
                    let distanceOfNewTopPoint: Double = self.distanceFrom(point: featureLocation, to: perpendicularLine)
                    if distanceOfNewTopPoint > distanceOfCurrentTopmostPoint {
                        topmostBoundingPointLocation?.setCoordinate(from: featureLocation.coordinate)
                    }
                }
            } else if self.point(featurePoint: featureLocation, isLeftTo: perpendicularLine) {
                if bottommostBoundingPointLocation == nil {
                    bottommostBoundingPointLocation = LocationWrapper(with: featureLocation.coordinate.latitude, longitude: featureLocation.coordinate.longitude)
                } else {
                    let distanceOfCurrentBottomPoint: Double = self.distanceFrom(point: bottommostBoundingPointLocation!, to: perpendicularLine)
                    let distanceOfNewBottomPoint: Double = self.distanceFrom(point: featureLocation, to: perpendicularLine)
                    if distanceOfNewBottomPoint > distanceOfCurrentBottomPoint {
                        bottommostBoundingPointLocation?.setCoordinate(from: featureLocation.coordinate)
                    }
                }
            } else {
                // point is contained in line
                continue
            }
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // 4. find corner points of the rect passing from top, left, right and bottom points
        
        let linePassingFromLeftPoint: GeometricLine = self.lineParallel(to: line, andPassingFrom: leftmostBoundingPointLocation!)
        let linePassingFromRightPoint: GeometricLine = self.lineParallel(to: line, andPassingFrom: rightmostBoundingPointLocation!)
        let linePassingFromTopPoint: GeometricLine = self.lineParallel(to: perpendicularLine, andPassingFrom: topmostBoundingPointLocation!)
        let linePassingFromBottomPoint: GeometricLine = self.lineParallel(to: perpendicularLine, andPassingFrom: bottommostBoundingPointLocation!)
        
        temp.append(self.pointLocation(fromIntersectionOf: linePassingFromTopPoint, and: linePassingFromLeftPoint)) // top left
        temp.append(self.pointLocation(fromIntersectionOf: linePassingFromBottomPoint, and: linePassingFromLeftPoint)) // bottom left
        temp.append(self.pointLocation(fromIntersectionOf: linePassingFromBottomPoint, and: linePassingFromRightPoint)) // bottom right
        temp.append(self.pointLocation(fromIntersectionOf: linePassingFromTopPoint, and: linePassingFromRightPoint)) // top right
        
        return temp
    }()

    enum CodingKeys: String, CodingKey {
        case mensPar
        case womensPar
        case mensHandicap
        case womensHandicap
        case holeId
        case courseId
        case courseVersion
        case holeTees
        case features
        case elevations
    }
    
    required init?(coder: NSCoder) {
        self.mensPar = coder.decodeInteger(forKey: CodingKeys.mensPar.rawValue)
        self.womensPar = coder.decodeInteger(forKey: CodingKeys.womensPar.rawValue)
        self.mensHandicap = coder.decodeFloat(forKey: CodingKeys.mensHandicap.rawValue)
        self.womensHandicap = coder.decodeFloat(forKey: CodingKeys.womensHandicap.rawValue)
        self.holeId = coder.decodeInteger(forKey: CodingKeys.holeId.rawValue)
        self.courseId = coder.decodeInteger(forKey: CodingKeys.courseId.rawValue)
        self.courseVersion = coder.decodeInteger(forKey: CodingKeys.courseVersion.rawValue)
        self.holeTees = coder.decodeArrayOfObjects(ofClass: CourseHoleTee.self, forKey: CodingKeys.holeTees.rawValue) ?? []
        self.features = coder.decodeArrayOfObjects(ofClass: CourseHoleFeature.self, forKey: CodingKeys.features.rawValue) ?? []
        self.elevations = coder.decodeArrayOfObjects(ofClass: CourseHoleElevation.self, forKey: CodingKeys.elevations.rawValue) ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.mensPar, forKey: CodingKeys.mensPar.rawValue)
        coder.encode(self.womensPar, forKey: CodingKeys.womensPar.rawValue)
        coder.encode(self.mensHandicap, forKey: CodingKeys.mensHandicap.rawValue)
        coder.encode(self.womensHandicap, forKey: CodingKeys.womensHandicap.rawValue)
        coder.encode(self.holeId, forKey: CodingKeys.holeId.rawValue)
        coder.encode(self.courseId, forKey: CodingKeys.courseId.rawValue)
        coder.encode(self.courseVersion, forKey: CodingKeys.courseVersion.rawValue)
        coder.encode(self.holeTees, forKey: CodingKeys.holeTees.rawValue)
        coder.encode(self.features, forKey: CodingKeys.features.rawValue)
        coder.encode(self.elevations, forKey: CodingKeys.elevations.rawValue)
    }
    
    
    
}

extension CourseHole {
    
    func distance() -> Distance {
        
        guard let tee = furthestTeeCenter,
            let green = greenCenter else {
                return Distance.zeroDistance()
        }
        
        return Distance(meters: tee.distance(from: green))
        
    }
    
    
    func getPar() -> Int {
        return mensPar
    }
    
    func getHandicap() -> Float {
        return mensHandicap
    }
}


//MARK: Map Helpers

extension CourseHole {
    

    func calculateLongestSideOfBoundingRectangle() -> CLLocationDistance {
        let boundingRectHeight = self.heightOfBoundingRectangle()
        let boundingRectWidth = self.widthOfBoundingRectangle()
        return max(boundingRectHeight, boundingRectWidth)
    }
    
    func heightOfBoundingRectangle() -> CLLocationDistance {
        let boundingRect = self.cornersOfBoundingRectangle
        let topLeft = boundingRect[0]
        let bottomLeft = boundingRect[1]
        
        return bottomLeft.location.distance(from: topLeft.location)
    }
    
    func widthOfBoundingRectangle() -> CLLocationDistance {
        let boundingRect = self.cornersOfBoundingRectangle
        let bottomLeft = boundingRect[1]
        let bottomRight = boundingRect[2]
        
        return bottomLeft.location.distance(from: bottomRight.location)
    }
    
    private func point(featurePoint: LocationWrapper, isRightTo line: GeometricLine) -> Bool {
        let y: Double = featurePoint.coordinate.latitude
        let axPlusC: Double = (line.a * featurePoint.coordinate.longitude) + line.c
        
        return y < axPlusC
    }
    
    private func point(featurePoint: LocationWrapper, isLeftTo line: GeometricLine) -> Bool {
        let y: Double = featurePoint.coordinate.latitude
        let axPlusC: Double = (line.a * featurePoint.coordinate.longitude) + line.c
        
        return y > axPlusC
    }
    
    private func distanceFrom(point: LocationWrapper, to line: GeometricLine) -> Double {
        let nom: Double = fabs((line.a * point.coordinate.longitude) + (line.b * point.coordinate.latitude) + line.c)
        let denom: Double = sqrt((line.a * line.a) + (line.b * line.b))
        return nom / denom
    }
    
    private func lineParallel(to line: GeometricLine, andPassingFrom location: LocationWrapper) -> GeometricLine {
        let b: Double = -1
        let c: Double = location.coordinate.latitude - (line.a * location.coordinate.longitude)
        return GeometricLine(a: line.a, b: b, c: c)
    }
    
    private func pointLocation(fromIntersectionOf firstLine: GeometricLine, and secondLine: GeometricLine) -> LocationWrapper {
        let x: Double = (firstLine.c - secondLine.c) / (secondLine.a - firstLine.a)
        let y: Double = (firstLine.a * x) + firstLine.c
        return LocationWrapper(with: y, longitude: x)
    }
}
