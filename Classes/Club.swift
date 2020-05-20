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
    public typealias userType = MembershipUser
    
    
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    public override func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) -> Error? {
        
        guard
            let decodedData = decodedData,
            let decodedDataString = decodedData.stringFromDecodedData()
            else {
                let error = CKError.nullDecodedDataString("The decoded data string is nil")
                return error
        }
        
        let userInformation = UserInformation(decodedDataString: decodedDataString)
        
        if let existingUser = getUser(with: userInformation.userId) {
            
            return updateUserInStorage(existingUser)
        } else {
            // This is a new user
            return createUser(with: userInformation)
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
    public func createUser(with userInformation: UserInformation) -> Error? {
        
        if let existingUser = getUser(with: userInformation.userId) {
            
            let error = CKError.userExistsAlready("Attempted to create a new user but one exists with this userId: \(String(describing: existingUser.userId)) and username: \(String(describing: existingUser.username))")
            return error
            
        } else {
            // This user does not exist and there is no error
            
            let user = MembershipUser()

            user.userId = userInformation.userId
            user.username = userInformation.username

            user.numVisits = 1
            user.timeStampOfLastVisit = Date().timeIntervalSince1970
            user.timeStampAdded = Date().timeIntervalSince1970
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(user)
                }
            } catch let error {
                return error
            }
        }
        
        return nil
    }
    
    /// Queries and returns a User object from storage matching the properties within the decodedDataString
    public func getUser(with userId: String) -> MembershipUser? {
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: MembershipUser.self, forPrimaryKey: userId)
            return user
        } catch let error {
            print("Error getting user: \(error)")
        }
        
        return nil
    }
    
    /// Updates a User object with new properties and re-saves it in storage
    public func updateUserInStorage(_ user: MembershipUser) -> Error? {
        
        do {
            let realm = try Realm()
            try realm.write {
                let previousNumberOfVisits = user.numVisits
                let updatedValue = previousNumberOfVisits + 1
                
                user.numVisits = updatedValue
                user.timeStampOfLastVisit = Date().timeIntervalSince1970
            }
        } catch let error {
            return error
        }
        
        return nil
    }
    
    /// Queries and deletes a User object from storage matching the properties within the decodedDataString
    public func deleteUser(with userId: String) -> Error? {
        if let user = getUser(with: userId) {
            return deleteUser(user)
        }
        
        let error = CKError.nonexistentUser("No such user exists")
        return error
    }
    
    /// Deletes a User object from storage
    public func deleteUser(_ user: MembershipUser) -> Error? {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(user)
            }
        } catch let error {
            return error
        }
        return nil
    }
    
}
