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
    
    
    
    typealias userType = MembershipUser
    
    override func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) {
        
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
    
    
    
    
    
    func createUser(with decodedDataString: String) {
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
    
    func getUser(with decodedDataString: String) -> MembershipUser? {
        
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
    
    func updateUserInStorage(_ user: MembershipUser) {
        
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
    
    func deleteUser(with decodedDataString: String) {
        if let user = getUser(with: decodedDataString) {
            deleteUser(user)
        }
    }
    
    func deleteUser(_ user: MembershipUser) {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(user)
            }
        } catch let error {
            print("Error getting user: \(error)")
        }
    }
    
    
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
