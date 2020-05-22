//
//  Constants.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 5/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct Constants {
    
    private init() {}
    
    struct SwiftUIConstants {
        
        private init() {}
        
        struct AppTheme {
            static let primaryColor: Color = Color.green
            static let secondaryColor: Color = Color.secondary
        }
        
        struct UIFormat {
            static let roundedCornerRadius: CGFloat = 10.0
            static let shadowRadius: CGFloat = 15.0
            static let roundedBorderWidth: CGFloat = 3
        }
        
        static func getBackgroundColor(from colorScheme: ColorScheme) -> Color {
            return colorScheme == .light ? Color.white : Color.black
        }
        
        static func getTextColor(from colorScheme: ColorScheme) -> Color {
            return colorScheme == .light ? Color.primary : Color.white
        }
    }
    
    struct ClassicSwiftConstants {
        
        private init() {}
        
    }
}
