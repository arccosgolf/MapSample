//
//  ArcCourseTee.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

class CourseTee: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let teeId: Int
    let name: String?
    let distance: Distance
    let slope: Float?
    let rating: Float?
    
    enum CodingKeys: String, CodingKey {
        case teeId
        case name
        case distance
        case slope
        case rating
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.teeId = try values.decode(Int.self, forKey: .teeId)
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
        if let dis = try values.decodeIfPresent(Double.self, forKey: .distance) {
            self.distance = Distance(meters: dis)
        }else{
            self.distance = Distance.zeroDistance()
        }
        self.slope = try values.decodeIfPresent(Float.self, forKey: .slope)
        self.rating = try values.decodeIfPresent(Float.self, forKey: .rating)
    }
    
    required init?(coder: NSCoder) {
        self.teeId = coder.decodeInteger(forKey: CodingKeys.teeId.rawValue)
        self.name = coder.decodeObject(of: NSString.self,forKey: CodingKeys.name.rawValue) as? String ?? ""
        self.distance = coder.decodeObject(of: Distance.self, forKey: CodingKeys.distance.rawValue) ?? Distance.zeroDistance()
        self.slope = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.slope.rawValue) as? Float ?? nil
        self.rating = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.rating.rawValue) as? Float ?? nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.teeId, forKey: CodingKeys.teeId.rawValue)
        coder.encode(self.name, forKey: CodingKeys.name.rawValue)
        coder.encode(self.distance, forKey: CodingKeys.distance.rawValue)
        coder.encode(self.slope, forKey: CodingKeys.slope.rawValue)
        coder.encode(self.rating, forKey: CodingKeys.rating.rawValue)
    }
}
