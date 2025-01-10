//
//  View.swift
//  LiveMapSwiftUI
//
//  Created by Greg Silesky on 10/19/23.
//

import SwiftUI

extension View {
    
    func montserratMedium(size: CGFloat) -> some View {
        return self.font(.montserratMedium(size: size))
    }
    
    func montserratMediumItalic(size: CGFloat) -> some View {
        return self.font(.montserratMediumItalic(size: size))
    }
    
    func montserratSemiBold(size: CGFloat) -> some View {
        return self.font(.montserratSemiBold(size: size))
    }
    
    func montserratSemiBoldItalic(size: CGFloat) -> some View {
        return self.font(.montserratSemiBoldItalic(size: size))
    }
    
    func montserratBold(size: CGFloat) -> some View {
        return self.font(.montserratBold(size: size))
    }
    
    func montserratBoldItalic(size: CGFloat) -> some View {
        return self.font(.montserratBoldItalic(size: size))
    }
    
    func montserratExtraBold(size: CGFloat) -> some View {
        return self.font(.montserratExtraBold(size: size))
    }
    
    func montserratExtraBoldItalic(size: CGFloat) -> some View {
        return self.font(.montserratExtraBoldItalic(size: size))
    }
}
