//
//  LocaleName.swift
//
//  Created by Greg Silesky on 6/29/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

class LocaleName: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let locale: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case locale
        case name
    }
    
    required init?(coder: NSCoder) {
        self.locale = coder.decodeObject(of: NSString.self, forKey: CodingKeys.locale.rawValue) as? String ?? ""
        self.name = coder.decodeObject(of: NSString.self, forKey: CodingKeys.name.rawValue) as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.locale, forKey: CodingKeys.locale.rawValue)
        coder.encode(self.name, forKey: CodingKeys.name.rawValue)
    }
    
}
