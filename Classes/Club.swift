//
//  Club.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture
import RealmSwift

public final class Club: CaptureMiddleware, CaptureMembershipProtocol {
    
    public static let shared = Club()
    
    private override init() {
        super.init()
    }
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    typealias userType = MembershipUser
    
    
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    public override func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) {
        
        guard
            let decodedData = decodedData,
            let decodedDataString = decodedData.stringFromDecodedData()
            else {
                return
        }
        
        if let existingUser = getUser(with: decodedDataString) {
            
            updateUserInStorage(existingUser)
            
        } else {
            // This is a new user
            createUser(with: decodedDataString)
        }
        
    }
    
    
    
    
    
    
    // Use to determine if the accrued time between punches
    // is within this time period.
    // If not, the user has been "punched in" for too long.
    // As if they have spent the night in the gym even after
    // business hours are over.
    public private(set) var dayPassHours: Int = 0
    
    private var maximumNumSecondsInDayPassHours: Int {
        let numSecondsInAnHour: Int = 60 * 60
        return dayPassHours * numSecondsInAnHour
    }
    public func setDayPass(hours: Int) {
        guard hours > 0 && hours <= 24 else {
            return
        }
        dayPassHours = hours
    }
    
    
    
    
    /// Creates a new User object in storage from the data within the decodedDataString
    public func createUser(with decodedDataString: String) {
        let user = MembershipUser()

        let parsedDecodedData = parseDecodedData(decodedDataString)
        user.userId = parsedDecodedData[ClubConstants.Keys.passUserIdKey]
        user.username = parsedDecodedData[ClubConstants.Keys.passNameKey]

        user.numVisits = 1
        user.timeStampOfLastVisit = Date().timeIntervalSince1970
        user.timeStampAdded = Date().timeIntervalSince1970
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user)
            }
        } catch let error {
            print("Error getting user: \(error)")
        }
    }
    
    /// Queries and returns a User object from storage matching the properties within the decodedDataString
    public func getUser(with decodedDataString: String) -> MembershipUser? {
        
        let parsedDecodedData = parseDecodedData(decodedDataString)
        guard let userId = parsedDecodedData[ClubConstants.Keys.passUserIdKey] else {
            return nil
        }
        
        do {
            let realm = try Realm()
            return realm.object(ofType: MembershipUser.self, forPrimaryKey: userId)
        } catch let error {
            print("Error getting user: \(error)")
        }
        
        return nil
    }
    
    /// Updates a User object with new properties and re-saves it in storage
    public func updateUserInStorage(_ user: MembershipUser) {
        
        do {
            let realm = try Realm()
            try realm.write {
                let previousNumberOfVisits = user.numVisits
                let updatedValue = previousNumberOfVisits + 1
                
                user.numVisits = updatedValue
                user.timeStampOfLastVisit = Date().timeIntervalSince1970
            }
        } catch let error {
            print("Error updating user: \(error)")
        }
    }
    
    /// Queries and deletes a User object from storage matching the properties within the decodedDataString
    public func deleteUser(with decodedDataString: String) {
        if let user = getUser(with: decodedDataString) {
            deleteUser(user)
        }
    }
    
    /// Deletes a User object from storage
    public func deleteUser(_ user: MembershipUser) {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(user)
            }
        } catch let error {
            print("Error getting user: \(error)")
        }
    }
    
    /// Parses a decodedDataString and returns a dictionary of the embedded values
    public func parseDecodedData(_ decodedDataString: String) -> [String: String] {
        let components = decodedDataString.components(separatedBy: "|")
        guard components.count == 4 else {
            fatalError("Unexpected decoded data format")
        }
        
        var values: [String: String] = [:]
        
        values[ClubConstants.Keys.passPayloadNumberKey] = components[0]
        values[ClubConstants.Keys.passUserIdKey] = components[1]
        values[ClubConstants.Keys.passPayloadKey] = components[2]
        values[ClubConstants.Keys.passNameKey] = components[3]
        
        return values
    }
    
}
