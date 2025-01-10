//
//  Course.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation
import CoreLocation

class Course: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true

    let courseId: Int
    let courseVersion: Int
    let mapTypeId: Int
    let name: String
    let location: CLLocation
    let city: String
    let state: String
    let country: String
    let phone: String?
    let numberOfHoles: Int
    let mensPar: Int
    let womensPar: Int
    let isLatest: Bool
    let courseUUID: UUID?
    let mapTiles: MapTiles?
    let courseTees: [CourseTee]
    var holes: [CourseHole]
    let courseLocaleName: [LocaleName]
    
    var firstHole : Int? {
        return self.holes.sorted(by: {$0.holeId < $1.holeId}).first?.holeId
    }
    
    var orderedHoles : [CourseHole] {
        return self.holes.sorted(by: {$0.holeId < $1.holeId})
    }
    
    lazy var mensTee: CourseTee? = {
        if self.orderedCourseTees.count >= 2 {
            return self.orderedCourseTees[1]
        } else if self.orderedCourseTees.count == 1 {
            return self.orderedCourseTees.first
        }
        return nil
    }()
    
    lazy var womensTee: CourseTee? = {
        return self.orderedCourseTees.last
    }()
    
    lazy var orderedCourseTees: [CourseTee] = {
        return self.courseTees.sorted(by: { (tee1, tee2) -> Bool in
            return tee1.distance > tee2.distance
        })
    }()
    
    var localizedName: String {
        
        guard let code = Locale.current.language.languageCode?.identifier else {
            return name
        }
        
        guard let localized = courseLocaleName.first(where: { $0.locale == code }) else {
            return name
        }
        
        return localized.name
        
    }
    
    enum CodingKeys: String, CodingKey {
        case courseId
        case courseVersion
        case mapTypeId
        case name
        case latitude
        case longitude
        case location
        case city
        case state
        case country
        case phone
        case numberOfHoles = "noOfHoles"
        case mensPar
        case womensPar
        case isLatest
        case courseUUID
        case mapTiles
        case courseTees
        case holes
        case courseLocaleName
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.courseId = try values.decode(Int.self, forKey: .courseId)
        self.courseVersion = try values.decode(Int.self, forKey: .courseVersion)
        self.mapTypeId = 1 //try values.decode(Int.self, forKey: .courseVersion)
        self.name = try values.decode(String.self, forKey: .name)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.city = try values.decode(String.self, forKey: .city)
        self.state = try values.decode(String.self, forKey: .state)
        self.country = try values.decode(String.self, forKey: .country)
        self.phone = try values.decodeIfPresent(String.self, forKey: .phone)
        self.numberOfHoles = try values.decode(Int.self, forKey: .numberOfHoles)
        self.mensPar = try values.decode(Int.self, forKey: .mensPar)
        self.womensPar = try values.decode(Int.self, forKey: .womensPar)
        self.isLatest = try values.decode(String.self, forKey: .isLatest) == "T" ? true : false
        self.courseUUID = try values.decodeIfPresent(UUID.self, forKey: .courseUUID)
        self.mapTiles = try values.decodeIfPresent(MapTiles.self, forKey: .mapTiles)
        self.courseTees = try values.decode([CourseTee].self, forKey: .courseTees)
        self.holes = []
        self.courseLocaleName = []//try values.decode([ArcLocaleName].self, forKey: .courseLocaleName)
    }
    
    required init?(coder: NSCoder) {
        self.courseId = coder.decodeInteger(forKey: CodingKeys.courseId.rawValue)
        self.courseVersion = coder.decodeInteger(forKey: CodingKeys.courseVersion.rawValue)
        self.mapTypeId = coder.decodeInteger(forKey: CodingKeys.mapTypeId.rawValue)
        self.name = coder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as? String ?? NSLocalizedString("Unknown Course", comment: "")
        self.location = coder.decodeObject(of: CLLocation.self, forKey: CodingKeys.location.rawValue) ?? CLLocation(latitude: 0, longitude: 0)
        self.city = coder.decodeObject(of: NSString.self, forKey: CodingKeys.city.rawValue) as? String ?? NSLocalizedString("Unknown City", comment: "")
        self.state = coder.decodeObject(of: NSString.self, forKey: CodingKeys.state.rawValue) as? String ?? NSLocalizedString("Unknown State", comment: "")
        self.country = coder.decodeObject(of: NSString.self, forKey: CodingKeys.country.rawValue) as? String ?? NSLocalizedString("Unknown Country", comment: "")
        self.phone = coder.decodeObject(of: NSString.self, forKey: CodingKeys.phone.rawValue) as? String ?? NSLocalizedString("Unknown Phone", comment: "")
        self.numberOfHoles = coder.decodeInteger(forKey: CodingKeys.numberOfHoles.rawValue)
        self.mensPar = coder.decodeInteger(forKey: CodingKeys.mensPar.rawValue)
        self.womensPar = coder.decodeInteger(forKey: CodingKeys.womensPar.rawValue)
        self.isLatest = coder.decodeBool(forKey: CodingKeys.isLatest.rawValue)
        self.courseUUID = coder.decodeObject(of: NSUUID.self, forKey: CodingKeys.courseUUID.rawValue) as? UUID
        self.mapTiles = coder.decodeObject(of: MapTiles.self, forKey: CodingKeys.mapTiles.rawValue)
        self.courseTees = coder.decodeArrayOfObjects(ofClass: CourseTee.self, forKey: CodingKeys.courseTees.rawValue) ?? []
        self.holes = coder.decodeArrayOfObjects(ofClass: CourseHole.self, forKey: CodingKeys.holes.rawValue) ?? []
        self.courseLocaleName = coder.decodeArrayOfObjects(ofClass: LocaleName.self, forKey: CodingKeys.courseLocaleName.rawValue) ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.courseId, forKey: CodingKeys.courseId.rawValue)
        coder.encode(self.courseVersion, forKey: CodingKeys.courseVersion.rawValue)
        coder.encode(self.mapTypeId, forKey: CodingKeys.mapTypeId.rawValue)
        coder.encode(self.name, forKey: CodingKeys.name.rawValue)
        coder.encode(self.location, forKey: CodingKeys.location.rawValue)
        coder.encode(self.city, forKey: CodingKeys.city.rawValue)
        coder.encode(self.state, forKey: CodingKeys.state.rawValue)
        coder.encode(self.country, forKey: CodingKeys.country.rawValue)
        coder.encode(self.phone, forKey: CodingKeys.phone.rawValue)
        coder.encode(self.numberOfHoles, forKey: CodingKeys.numberOfHoles.rawValue)
        coder.encode(self.mensPar, forKey: CodingKeys.mensPar.rawValue)
        coder.encode(self.womensPar, forKey: CodingKeys.womensPar.rawValue)
        coder.encode(self.isLatest, forKey: CodingKeys.isLatest.rawValue)
        coder.encode(self.courseUUID, forKey: CodingKeys.courseUUID.rawValue)
        coder.encode(self.mapTiles, forKey: CodingKeys.mapTiles.rawValue)
        coder.encode(self.courseTees, forKey: CodingKeys.courseTees.rawValue)
        coder.encode(self.holes, forKey: CodingKeys.holes.rawValue)
        coder.encode(self.courseLocaleName, forKey: CodingKeys.courseLocaleName.rawValue)
    }
    
}

//MARK: Helpers

extension Course {
    
    func hole(for holeId: Int) -> CourseHole? {
        return holes.first(where: { (hole) -> Bool in
            return hole.holeId == holeId
        })
    }
    
    func teeBox(for teeId: Int) -> CourseTee? {
        return courseTees.first(where: { (tee) -> Bool in
            return tee.teeId == teeId
        })
    }
    
    func distance(fromCourseTo location: CLLocation) -> Distance {
        return Distance(meters: location.distance(from: self.location))
    }
}
