//
//  CourseHoleTee.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

class CourseHoleTee: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let teeId: Int
    let name: String?
    let distance: Distance
    
    enum CodingKeys: String, CodingKey {
        case teeId
        case name
        case distance
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
    }
    
    required init?(coder: NSCoder) {
        self.teeId = coder.decodeInteger(forKey: CodingKeys.teeId.rawValue)
        self.name = coder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as? String ?? ""
        self.distance = coder.decodeObject(of: Distance.self, forKey: CodingKeys.distance.rawValue) ?? Distance.zeroDistance()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.teeId, forKey: CodingKeys.teeId.rawValue)
        coder.encode(self.name, forKey: CodingKeys.name.rawValue)
        coder.encode(self.distance, forKey: CodingKeys.distance.rawValue)
    }
    
}
