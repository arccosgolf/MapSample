//
//  MapTiles.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

class MapTiles: NSObject, NSSecureCoding, Decodable {
    static var supportsSecureCoding: Bool = true
    
    let mapTileId: UUID?
    let mapTileSource: String?
    let mapTileAttribution: String?
    let minZ: Int
    let maxZ: Int
    
    enum CodingKeys: String, CodingKey {
        case mapTileId
        case mapTileSource
        case mapTileAttribution
        case minZ
        case maxZ
    }
    
    required init?(coder: NSCoder) {
        self.mapTileId = coder.decodeObject(of: NSUUID.self, forKey: CodingKeys.mapTileId.rawValue) as? UUID
        self.mapTileSource = coder.decodeObject(of: NSString.self, forKey: CodingKeys.mapTileSource.rawValue) as? String
        self.mapTileAttribution = coder.decodeObject(of: NSString.self, forKey: CodingKeys.mapTileAttribution.rawValue) as? String
        self.minZ = coder.decodeInteger(forKey: CodingKeys.minZ.rawValue)
        self.maxZ = coder.decodeInteger(forKey: CodingKeys.maxZ.rawValue)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.mapTileId, forKey: CodingKeys.mapTileId.rawValue)
        coder.encode(self.mapTileSource, forKey: CodingKeys.mapTileSource.rawValue)
        coder.encode(self.mapTileAttribution, forKey: CodingKeys.mapTileAttribution.rawValue)
        coder.encode(self.minZ, forKey: CodingKeys.minZ.rawValue)
        coder.encode(self.maxZ, forKey: CodingKeys.maxZ.rawValue)
    }
}
