//
//  MembershipUser.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import RealmSwift

/// A default object which represents a user. May be subclassed
@objcMembers open class MembershipUser: Object, Codable, IdentifiableUserProtocol, Identifiable {
    
    public dynamic var memberId: String?
    
    public dynamic var passId: String?
    
    public dynamic var username: String?
    
    public dynamic var timeStampAdded: Double = 0.0
    
    /// Number of times that the user has visited (or scanned their mobile pass)
    public dynamic var numVisits: Int = 0
    
    /// Timestamp (in milliseconds since January 1, 1970) of the last visit
    public dynamic var timeStampOfLastVisit: Double = 0.0
    
    /// A RealmSwift - specific default initializer
    public required init() {
        super.init()
    }

    /// A RealmSwift - specific property for querying
    public override class func primaryKey() -> String? {
        return MembershipUser.CodingKeys.memberId.rawValue
    }
    
    /// Required initializer as part of conformance to Decodable protocol
    /// If overriding the MembershipUser class, be sure to override this initializer, call `super.init(from:)`
    /// and try to decode the properties in your subclass
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        memberId = try container.decode(String.self, forKey: .memberId)
        passId = try container.decode(String.self, forKey: .passId)
        username = try container.decode(String.self, forKey: .username)
        
        // In the case where the decoded items are CSVs,
        // all the values will be Strings
        // In such a case where the expected value is NOT a String
        // cast the return value back to the expected value type
        if let timeStampAddedDoubleValue = try? container.decode(Double.self, forKey: .timeStampAdded) {
            timeStampAdded = timeStampAddedDoubleValue
        } else if let timeStampAddedStringValue = try? container.decode(String.self, forKey: .timeStampAdded) {
            // CSV return String for this variable. Cast back to original value type
            timeStampAdded = Double(timeStampAddedStringValue) ?? 0
        }
                
        if let numVisitsIntValue = try? container.decode(Int.self, forKey: .numVisits) {
            numVisits = numVisitsIntValue
        } else if let numVisitsStringValue = try? container.decode(String.self, forKey: .numVisits) {
            numVisits = Int(numVisitsStringValue) ?? 0
        }
        
        if let timeStampOfLastVisitDoubleValue = try? container.decode(Double.self, forKey: .timeStampOfLastVisit) {
            timeStampOfLastVisit = timeStampOfLastVisitDoubleValue
        } else if let timeStampOfLastVisitStringValue = try? container.decode(String.self, forKey: .timeStampOfLastVisit) {
            timeStampOfLastVisit = Double(timeStampOfLastVisitStringValue) ?? 0
        }
        
        super.init()
    }
    
    /// Required as part of Encodable protocol.
    /// If overriding the MembershipUser class, be sure to override this function, call `super.encode(to:)`
    /// and try to encode the properties in your subclass
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(memberId, forKey: .memberId)
        try container.encode(passId, forKey: .passId)
        try container.encode(username, forKey: .username)
        try container.encode(timeStampAdded, forKey: .timeStampAdded)
        try container.encode(numVisits, forKey: .numVisits)
        try container.encode(timeStampOfLastVisit, forKey: .timeStampOfLastVisit)
        
    }
    
    /// Returns array of string representation of MembershipUser variable names
    /// If overriding the MembershipUser class, be sure to override this function and combine
    /// the resulting array from the `super.variableNamesAsStrings()` and the variable
    /// names in your names your subclass
    /// Used for Codable protocol
    open class func variableNamesAsStrings() -> [String] {
        return CodingKeys.allCases.map { $0.rawValue }
    }

    /// enum for string representation of variable names. Used for Codable protocol
    internal enum CodingKeys: String, CodingKey, CaseIterable {
        case memberId
        case passId
        case username
        case timeStampAdded
        case numVisits
        case timeStampOfLastVisit
    }
}














// MARK: - MembershipUserCollection

/// A wrapper for RealmSwift-related query on MemberShipUser
/// without exposing the RealmSwift framework
public typealias MembershipUserChanges<T: MembershipUser> = RealmCollectionChange<Results<T>>

/// Maintains self-updating collection of MembershipUsers
public class MembershipUserCollection<T: MembershipUser>: NSObject {
    
    /// Results collection of MembershipUsers
    public private(set) var users: Results<T>!
    
    public var count: Int {
        return users?.count ?? 0
    }
    
    public func user(at index: Int) -> T? {
        return users?[index]
    }
    
    private var usersToken: NotificationToken?
    
    public override init() {
        super.init()
    }
    
    /// Observes changes to MembershipUser records
    ///
    /// - Parameters:
    ///   - completion: Provides all changes such as insertions, deletions, modifications and initial result of the collection of MembershipUser records. Use this to update UI (such as UITableView and UICollectionViews) with updated records.
    open func observeAllRecords(_ completion: @escaping (MembershipUserChanges<T>) -> ()) {
        guard let allUsers = RealmLayer.shared.queryForUsers(ofType: T.self, predicate: nil) else {
            let error = CKError.invalidRealmLayer("Failed to initialize Realm instance")
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error getting user: \(error)")
            return
        }
        users = allUsers
        usersToken = users.observe({ (changes) in
            completion(changes)
        })
    }
    
    open func stopObserving() {
        usersToken?.invalidate()
    }
}
