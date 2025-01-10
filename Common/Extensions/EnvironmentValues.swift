//
//  EnvironmentValues.swift
//  MapSample
//
//  Created by Greg Silesky on 1/6/25.
//

import SwiftUI

extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? EdgeInsets()
    }
}

struct ScreenFrameKey: EnvironmentKey {
    static var defaultValue: CGRect {
        UIApplication.shared.keyWindow?.frame ?? CGRect.zero
    }
}

extension EnvironmentValues {
    var frame: CGRect {
        self[ScreenFrameKey.self]
    }
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}
