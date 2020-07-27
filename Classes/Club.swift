//
//  Club.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture
import RealmSwift
import SKTCapture

public final class Club: CaptureMiddleware, CaptureMembershipProtocol, ClubKitProtocol {
    
    // MARK: - Variables
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    /// May be overriden by providing your own custom MembershipUser class type
    /// in the `setCustomMembershipUser(classType:)` function during initialization
    public typealias userType = MembershipUser
    
    /// Gives developer the opportunity to use their own MembershipUser subclasses
    /// Will override the default MembershipUser class that is used in typical operations
    public private(set) var OverridableMembershipUserClassType: MembershipUser.Type = MembershipUser.self
    
    public static let shared = Club(capture: CaptureHelper.sharedInstance)
    
    public private(set) weak var delegate: ClubMiddlewareDelegate?
    
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers (PRIVATE / Singleton)
    
    private init(capture: CaptureHelper) {
        super.init()
        super.setCapture(instance: capture)
    }
    
    public override func onDecodedData(decodedData: CaptureLayerDecodedData?, device: CaptureLayerDevice) -> Error? {
        
        guard let decodedData = decodedData else {
            let error = CKError.nullDecodedData("The decoded data proeprty is nil")
            return error
        }
        
        guard let captureDataString = decodedData.stringFromDecodedData() else {
            let error = CKError.nonExistentUTF8DecodedDataString("The decoded data property could not be translated to a UTF8 String")
            return error
        }
        
        guard let captureDataInformation = CaptureDataInformation(captureDataString: captureDataString) else {
            let error = CKError.invalidPassInformation("Unexpected pass format. Could not find user information.")
            return error
        }
        
        if let existingUser = getUser(with: captureDataInformation.userId) {
            
            updateVisits(for: existingUser)
        } else {
            // This is a new user
            createUser(with: captureDataInformation)
        }
        
        return nil
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
    
    override func setupCaptureLayer() -> SKTCaptureLayer {
        
        let captureLayer = SKTCaptureLayer()
        super.capture.pushDelegate(captureLayer)
        
        captureLayer.deviceManagerArrivalHandler = { (deviceManager, result) in
            self.delegate?.capture?(self, didNotifyArrivalForManager: deviceManager, result: result)
        }
        captureLayer.deviceManagerRemovalHandler = { (deviceManager, result) in
            self.delegate?.capture?(self, didNotifyRemovalForManager: deviceManager, result: result)
        }
        captureLayer.deviceArrivalHandler = { (device, result) in
            self.delegate?.capture?(self, didNotifyArrivalFor: device, result: result)
        }
        captureLayer.deviceRemovalHandler = { (device, result) in
            self.delegate?.capture?(self, didNotifyRemovalFor: device, result: result)
        }
        captureLayer.batteryLevelChangeHandler = { (batteryLevel, device) in
            self.delegate?.capture?(self, batteryLevelDidChange: batteryLevel, for: device)
        }
        captureLayer.captureDataHandler = { (decodedData, device, result) in
            self.delegate?.capture?(self, didReceive: decodedData, for: device, withResult: result)
            if let possibleError = self.onDecodedData(decodedData: decodedData, device: device) {
                self.delegate?.club?(self, didReceive: possibleError)
            }
        }
        return captureLayer
    }
    
}















// MARK: - Setup Functions

extension Club {
    
    @discardableResult
    public func setDelegate(to: ClubMiddlewareDelegate) -> Club {
        self.delegate = to
        return self
    }
    
    @discardableResult
    public func setCustomMembershipUser(classType: MembershipUser.Type) -> Club {
        OverridableMembershipUserClassType = classType
        return self
    }
    
    
}















// MARK: - API

extension Club {
    
    public func createUser(with captureDataInformation: CaptureDataInformation) {
        
        if let existingUser = getUser(with: captureDataInformation.userId) {
            
            let error = CKError.userExistsAlready("Attempted to create a new user but one exists with this userId: \(String(describing: existingUser.userId)) and username: \(String(describing: existingUser.username))")
            
            delegate?.club?(self, didReceive: error)
            
        } else {
            // This user does not exist and there is no error
            
            let user = OverridableMembershipUserClassType.init()

            user.userId = captureDataInformation.userId
            user.username = captureDataInformation.username
            
            let currentDateTimestamp = Date().timeIntervalSince1970

            user.numVisits = 1
            user.timeStampOfLastVisit = currentDateTimestamp
            user.timeStampAdded = currentDateTimestamp
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(user)
                    delegate?.club?(self, didCreateNewMembership: user)
                }
            } catch let error {
                delegate?.club?(self, didReceive: error)
            }
        }
    }
    
    public func merge(importedUsers: [MembershipUser]) {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(importedUsers, update: Realm.UpdatePolicy.modified)
            }
        } catch let error {
            delegate?.club?(self, didReceive: error)
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error getting user: \(error)")
        }
    }
    
    public func getUser(with userId: String) -> MembershipUser? {
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: OverridableMembershipUserClassType.self, forPrimaryKey: userId)
            return user
        } catch let error {
            delegate?.club?(self, didReceive: error)
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error getting user: \(error)")
        }
        
        return nil
    }
    
    private func updateVisits(for user: MembershipUser) {
        self.update(user: user) {
            let previousNumberOfVisits = user.numVisits
            let updatedValue = previousNumberOfVisits + 1
            
            user.numVisits = updatedValue
            user.timeStampOfLastVisit = Date().timeIntervalSince1970
            
            delegate?.club?(self, didUpdateMembership: user)
        }
    }
    
    public func update(user: MembershipUser, withChanges changes: () -> ()) {
        do {
            let realm = try Realm()
            try realm.write {
                
                // Perform changes to user object and update in Realm
                changes()
            }
        } catch let error {
            delegate?.club?(self, didReceive: error)
        }
    }
    
    public func deleteUser(with userId: String) {
        if let user = getUser(with: userId) {
            deleteUser(user)
        } else {
            
            let error = CKError.nonexistentUser("No such user exists")
            delegate?.club?(self, didReceive: error)
        }
    }
    
    public func deleteUser(_ user: MembershipUser) {
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(user)
                delegate?.club?(self, didDeleteMembership: user)
            }
        } catch let error {
            delegate?.club?(self, didReceive: error)
        }
    }
}
