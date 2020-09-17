//
//  RealmLayer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 9/2/20.
//

import RealmSwift

/// Provides abstraction layer for performing Realm operations
class RealmLayer: NSObject {
    
    private var realm: Realm?
    
    /// Error for if the do-try-catch block fails when initializing realm instance
    private var realmInitializationError: Error?
    
    private var migrationChanges: [MigrationChange] = []
    
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers
    
    init(migrationChanges: [MigrationChange]) {
        super.init()
        self.migrationChanges = migrationChanges
        initializeRealmInstance()
    }
    
    
    
    private func initializeRealmInstance() {
        do {
            let realmConfiguration = setupRealmConfiguration()
            try realm = Realm(configuration: realmConfiguration)
        } catch let error {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error initializing Realm instance: \(error)")
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
    
        let config = Realm.Configuration(
        schemaVersion: currentRealmSchemaVersion(),
        migrationBlock: { [unowned self] (migration: Migration, oldSchemaVersion: UInt64) in
            
            let migrationChanges = self.getAllVersions(startingAfter: oldSchemaVersion)
            
            migrationChanges.forEach { (migrationChange) in
                migrationChange.changeBlock(migration)
            }
        })
        
        return config
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /// Returns the current schema version stored to UserDefaults. 0 if no migrations have been performed
    private func currentRealmSchemaVersion() -> UInt64 {
        if let storedVersion = UserDefaults.standard.value(forKey: ClubConstants.RealmLayer.versionUserDefaultsKey) as? UInt64 {
            return storedVersion
        }
        return 0
    }
    
    /**
     Creates a subset of array of all MigrationChange objects starting after
     the designated version
     
     Example:
     oldSchemaVersion: 3
     
     all MigrationChange objects (Using their version UInt64 variable as the array value. Not their index position within the array):
     [1, 2, 3, 4, 5, 6, 7]
     
     By adding 1 to the `oldSchemaVersion`, create subset starting from 4 through 7
     
     - Parameters:
        - oldSchemaVersion: The outdated chema version used for the Realm configuration. This version is supplied when a migration is required due to modifying a Realm Object
     */
    internal func getAllVersions(startingAfter oldSchemaVersion: UInt64) -> [MigrationChange] {
        
        guard let latestVersionMigration = migrationChanges.last else {
            return []
        }
        
        // Add 1 to oldSchemaVersion.
        var startingVersionIndex = Int(oldSchemaVersion + 1)
        
        let latestVersionIndex = Int(latestVersionMigration.version)
        
        // Avoid out-of-bounds range such as: 3...2
        // The lower bound (left) must be less than the upper bound (right)
        // If the lower bound is greater than the upper bound, re-set it to maximum possible value, which changes to range to: 2...2
        // In other words, the range will consist of only the last item.
        if startingVersionIndex > latestVersionIndex {
            startingVersionIndex = latestVersionIndex
        }
        
        let range: ClosedRange<Int> = (startingVersionIndex...latestVersionIndex)
        
        
        
        
        var migrationChanges: [MigrationChange] = []
        
        for version in range {
            guard let migrationChange = self.migrationChanges.filter({ $0.version == version }).first else {
                // May never happen
                continue
            }
            migrationChanges.append(migrationChange)
        }
        
        return migrationChanges
    }
}
