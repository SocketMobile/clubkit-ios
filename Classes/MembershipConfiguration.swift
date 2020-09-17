//
//  MembershipConfiguration.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 9/14/20.
//

import RealmSwift

public struct MembershipConfiguration {
    
    public enum UserCreation: Equatable {
        public static func ==(lhs: UserCreation, rhs: UserCreation) -> Bool {
            switch (lhs, rhs) {
            case (let .withSatisfied(booleanExpression1), let .withSatisfied(booleanExpression2)):
                return booleanExpression1() == booleanExpression2()
            case (.automaticallyOnScan, .automaticallyOnScan):
                return true
            default:
                return false
            }
        }
        
        /// New users are automatically created when passes are scanned
        case automaticallyOnScan
        
        /**
         New users are only created after some boolean condition is satisfied
         - Parameters:
            - condition: Completion block expected to return a boolean expression. New users will only be created if and only if this condition is true at the time passes are scanned
        */
        case withSatisfied(condition: () -> (Bool))
    }
    
    /// Enum for determining how users will be created
    /// when passes are scanned.
    public var userCreationStyle: UserCreation = .automaticallyOnScan
    
    public var migrationChanges: [MigrationChange] = []
    
    /// Default configuration
    public static var `default`: MembershipConfiguration {
        var config = MembershipConfiguration()
        config.userCreationStyle = .automaticallyOnScan
        config.migrationChanges = []
        return config
    }
    
}
