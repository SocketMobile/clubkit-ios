//
//  MembershipUser.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import RealmSwift

class RealmMembershipUser: Object, IdentifiableUserProtocol {
    
    @objc dynamic var numVisits: Int = 0
    @objc dynamic var timeStampOfLastVisit: Double = 0.0
    @objc dynamic var timeStampAdded: Double = 0.0
    @objc dynamic var userId: String?
    @objc dynamic var username: String?
    
//    required init() {
//        super.init()
//    }
//
//    override class func primaryKey() -> String? {
//        return "userId"
//    }
}
