//
//  MembershipUser.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import RealmSwift

/// A default object which represents a user. May be subclassed
open class MembershipUser: Object, IdentifiableUserProtocol, Identifiable {
    
    /// Unique identifier for this user (Often supplied within the Mobile Pass)
    @objc public dynamic var userId: String?
    
    /// Username for the user (Often supplied within the Mobile Pass)
    @objc public dynamic var username: String?
    
    /// Timestamp (in milliseconds since January 1, 1970) of this user's creation date
    @objc public dynamic var timeStampAdded: Double = 0.0
    
    /// Number of times that the user has visited (or scanned their mobile pass)
    @objc public dynamic var numVisits: Int = 0
    
    /// Timestamp (in milliseconds since January 1, 1970) of the last visit
    @objc public dynamic var timeStampOfLastVisit: Double = 0.0
    
    /// A RealmSwift - specific default initializer
    public required init() {
        super.init()
    }

    /// A RealmSwift - specific property for querying
    public override class func primaryKey() -> String? {
        return ClubConstants.RealmQueryConstants.userId
    }
    
}
