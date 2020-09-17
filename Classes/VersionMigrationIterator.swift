//
//  VersionMigrationIterator.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 9/17/20.
//

import RealmSwift

public typealias VersionMigrationChangeBlock = (Migration) -> ()

public class MigrationChange: NSObject {
    let version: UInt64
    let changeBlock: VersionMigrationChangeBlock
    init(version: UInt64, changeBlock: @escaping VersionMigrationChangeBlock) {
        self.version = version
        self.changeBlock = changeBlock
    }
}

internal class VersionMigrationIterator: NSObject {
    
    private var migrationChanges: [MigrationChange] = []
    
    @discardableResult
    internal func addVersionMigration(changeBlock: @escaping VersionMigrationChangeBlock) -> VersionMigrationIterator {
        
        var version: UInt64
        
        if migrationChanges.isEmpty {
            version = 1
        } else {
            version = UInt64(migrationChanges.count + 1)
        }
        
        UserDefaults.standard.set(version, forKey: ClubConstants.RealmLayer.versionUserDefaultsKey)
        
        let migrationChange = MigrationChange(version: version, changeBlock: changeBlock)
        
        migrationChanges.append(migrationChange)
        
        return self
    }
    
    internal func build() -> [MigrationChange] {
        return migrationChanges
    }
}
