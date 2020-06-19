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
        
        static let userListFileExtension: String = "mbus"
        static let csvFileExtension: String = "csv"
    }
    
    struct DebugMode {
        
        private init() {}
        
        static let debugModeUserDefaultsKey: String = "com.socketmobile.clubkit.debug-mode.user-defaults-key"
        static let debugModeActivatedKey: String = "com.socketmobile.clubkit.userdefaultskey.debug-mode.is-activated"
    }
    
    struct RealmQueryConstants {
        
        private init() {}
        
        static let userId = "userId"
    }
}
