//
//  Terrian.swift
//
//  Created by Greg Silesky on 6/27/23.
//  Copyright © 2023 Arccos Golf LLC. All rights reserved.
//

import Foundation

enum Terrain: Int {
    case unknown
    case fairway
    case leftOfFairway
    case rightOfFairway
    case sand
    case chipPitch
    case green
    case fringe
    case teeBox
    case teeBoxParThree
    
    var stringValue: String {
        switch self {
        case .unknown:
            return "UNKNOWN"
        case .fairway:
            return "FAIRWAY"
        case .leftOfFairway:
            return "FAIRWAY_LEFT"
        case .rightOfFairway:
            return "FAIRWAY_RIGHT"
        case .sand:
            return "SAND"
        case .chipPitch:
            return "CHIP"
        case .green:
            return "GREEN"
        case .fringe:
            return "FRINGE"
        case .teeBox, .teeBoxParThree:
            return "TEEBOX"
        @unknown default:
            return "UNKNOWN"
        }
    }
}
