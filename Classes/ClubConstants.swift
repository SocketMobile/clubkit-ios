//
//  ClubConstants.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import Foundation

// Constants such as strings, integer values, etc.
// that are used throughout the framework
internal struct ClubConstants {
    
    private init() {}
    
    struct IOFileType {
        private init() {}
        // Unique file extensions
        // for membership user list and membership user csv list, respectively
        static let userListFileExtension: String = "musrl"
        static let csvFileExtension: String = "mucsv"
    }
    
    struct DebugMode {
        
        private init() {}
        
        static let debugModeActivatedKey: String = "com.socketmobile.clubkit.userdefaultskey.debug-mode.is-activated"
    }
    
    struct RealmLayer {
        static let versionUserDefaultsKey = "com.socketmobile.ClubKit.RealmLayer.latestRealmConfigurationKey"
    }
}
