//
//  Color.swift
//  LiveMapSwiftUI
//
//  Created by Greg Silesky on 10/19/23.
//

import SwiftUI

extension Color {
    
    
    //*****************************************************************************/
    // MARK: - Standard Colors (Only use the colors below)
    //*****************************************************************************/
    
    static func standardGreen(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.34, green: 0.76, blue: 0.44, alpha: alpha))
    }
    
    static func standardDarkGreen(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.19, green: 0.53, blue: 0.27, alpha: alpha))
    }
    
    static func standardGray_14(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.14, green: 0.15, blue: 0.16, alpha: alpha))
    }
    
    static func standardGray_25(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.24, green: 0.25, blue: 0.27, alpha: alpha))
    }
    
    static func standardGray_42(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.39, green: 0.41, blue: 0.47, alpha: alpha))
    }
    
    static func standardGray_67(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.63, green: 0.68, blue: 0.72, alpha: alpha))
    }
    
    static func standardGray_83(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.82, green: 0.84, blue: 0.85, alpha: alpha))
    }
    
    static func standardYellow(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.93, green: 0.86, blue: 0.44, alpha: alpha))
    }
    
    static func standardDarkYellow(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.55, green: 0.47, blue: 0.26, alpha: alpha))
    }
    
    static func standardOrange(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.96, green: 0.61, blue: 0.36, alpha: alpha))
    }
    
    static func standardRed(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.95, green: 0.4, blue: 0.4, alpha: alpha))
    }
    
    static func standardBlue(_ alpha: CGFloat = 1) -> Color {
        Color(UIColor(red: 0.35, green: 0.74, blue: 1, alpha: alpha))
    }
    
}
