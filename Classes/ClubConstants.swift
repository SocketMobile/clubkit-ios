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
    
    struct Keys {
        
        private init() {}
        
        static let passPayloadNumberKey: String = "num"
        static let passUserIdKey: String = "id"
        static let passPayloadKey: String = "payloaad"
        static let passNameKey: String = "name"
    }
    
    struct RealmQueryConstants {
        
        private init() {}
        
        static let userId = "userId"
    }
}
