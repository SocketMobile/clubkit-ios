//
//  RealmLayer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 9/2/20.
//

import RealmSwift

/// Provides abstraction layer for performing Realm operations
class RealmLayer: NSObject {
    
    static let shared = RealmLayer()
    
    private(set) var realm: Realm?
    
    /// Error for if the do-try-catch block fails when initializing realm instance
    private var realmInitializationError: Error?
    
    private override init() {
        super.init()
        
        Realm.Configuration.defaultConfiguration = setupRealmConfiguration()
        
        do {
            try realm = Realm()
        } catch let error {
            realmInitializationError = error
        }
    }
    
    internal func queryFor<T: MembershipUser>(userType: T.Type, primaryKey: String) -> MembershipUser? {
        guard let realm = realm else {
            return nil
        }
        return realm.object(ofType: userType, forPrimaryKey: primaryKey)
    }
    
    internal func queryForUsers<T: MembershipUser>(ofType userType: T.Type, predicate: NSPredicate?) -> Results<T>? {
        guard let realm = realm else {
            return nil
        }
        
        let objects = realm.objects(userType)
        
        if let predicate = predicate {
            return objects.filter(predicate)
        } else {
            return objects
        }
    }
    
    /**
     Perform write operations using the block argument
     
     - Parameters:
        - block: Returns a Realm object if an instance has been successfully initialized and this instance can perform write operations. Otherwise an error is returned
     */
    internal func write(block: (Realm?, Error?) -> ()) {
        
        guard let realm = realm else {
            let error = CKError.invalidRealmLayer("Failed to initialize Realm instance")
            block(nil, realmInitializationError ?? error)
            return
        }
        
        do {
            try realm.write({
                block(realm, nil)
            })
        } catch let error {
            block(nil, error)
        }
    }
    
    /// Handles migrations for when the structure of the MembershipUser core object changes
    private func setupRealmConfiguration() -> Realm.Configuration {
        
        // Needs to be incremented whenever the structure
        // of a Realm object is modified
        let currentRealmSchemaVersion: UInt64 = RealmSchemaVersions.currentVersion
        
        let config = Realm.Configuration(
        schemaVersion: currentRealmSchemaVersion,
        migrationBlock: { migration, oldSchemaVersion in
            
            // At this version, the userId was split into memberId and passId
            if (oldSchemaVersion < RealmSchemaVersions.MigrationChanges.splitUserId.rawValue) {
                
                let membershipUserClass = Club.shared.OverridableMembershipUserClassType.className()
                
                // The enumerateObjects(ofType:_:) method iterates
                // over every User object stored in the Realm file
                migration.enumerateObjects(ofType: membershipUserClass) { oldObject, newObject in
                    newObject?[MembershipUser.CodingKeys.memberId.rawValue] = UUID().uuidString
                    newObject?[MembershipUser.CodingKeys.passId.rawValue] = oldObject?["userId"] as? String
                }
            }
            
            // Pending further changes...
        })
        
        return config
    }
}

/// Provides internal descriptions/comments for major changes
/// made to the Realm MembershipUser schema at each particular version
/// Purpose is to handle migrations due to such changes
fileprivate struct RealmSchemaVersions {
    
    static let currentVersion: UInt64 = MigrationChanges.splitUserId.rawValue
    
    enum MigrationChanges: UInt64 {
        case firstVersion = 0
        // Split the MembershipUser.userId property into
        // the memberId and passId
        case splitUserId
    }
}
