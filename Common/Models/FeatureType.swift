//
//  FeatureType.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

enum FeatureType: Int {
    case unknown = 0
    case green = 1
    case greenSandtrap = 2
    case fairwaySandtrap = 3
    case fairwayWaterHazard = 4
    case greenWaterHazard = 5
    case teebox = 6
    case teeboxOld = 27
    case fairway = 7
    case fairwayCenter = 8
    case trees = 9
    case boundingBox = 10
    
    init(for featureId: Int) {
        
        switch featureId {
        case 0:
            self = .unknown
        case 1:
            self = .green
        case 2:
            self = .greenSandtrap
        case 3:
            self = .fairwaySandtrap
        case 4:
            self = .fairwayWaterHazard
        case 5:
            self = .greenWaterHazard
        case 6:
            self = .teebox
        case 27:
            self = .teeboxOld
        case 7:
            self = .fairway
        case 8:
            self = .fairwayCenter
        case 9:
            self = .trees
        case 10:
            self = .boundingBox
        default:
            self = .unknown
        }
        
    }
    
}
