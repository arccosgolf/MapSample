//
//  Font.swift
//  LiveMapSwiftUI
//
//  Created by Greg Silesky on 10/19/23.
//

import SwiftUI

extension Font {
    
    fileprivate static let montserratMedium = "Montserrat-Medium"
    fileprivate static let montserratMediumItalic = "Montserrat-MediumItalic"
    fileprivate static let montserratSemiBold = "Montserrat-SemiBold"
    fileprivate static let montserratSemiBoldItalic = "Montserrat-SemiBoldItalic"
    fileprivate static let montserratBold = "Montserrat-Bold"
    fileprivate static let montserratBoldItalic = "Montserrat-BoldItalic"
    fileprivate static let montserratExtraBold = "Montserrat-ExtraBold"
    fileprivate static let montserratExtraBoldItalic = "Montserrat-ExtraBoldItalic"
    
    static func montserratMedium(size: CGFloat) -> Font {
        return Font.custom(Font.montserratMedium, size: size)
    }
    
    static func montserratMediumItalic(size: CGFloat) -> Font {
        return Font.custom(Font.montserratMediumItalic, size: size)
    }
    
    static func montserratSemiBold(size: CGFloat) -> Font {
        return Font.custom(Font.montserratSemiBold, size: size)
    }
    
    static func montserratSemiBoldItalic(size: CGFloat) -> Font {
        return Font.custom(Font.montserratSemiBoldItalic, size: size)
    }
    
    static func montserratBold(size: CGFloat) -> Font {
        return Font.custom(Font.montserratBold, size: size)
    }
    
    static func montserratBoldItalic(size: CGFloat) -> Font {
        return Font.custom(Font.montserratBoldItalic, size: size)
    }
    
    static func montserratExtraBold(size: CGFloat) -> Font {
        return Font.custom(Font.montserratExtraBold, size: size)
    }
    
    static func montserratExtraBoldItalic(size: CGFloat) -> Font {
        return Font.custom(Font.montserratExtraBoldItalic, size: size)
    }
}

