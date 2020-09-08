//
//  Club.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture
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
    
    public static var Configuration: MembershipConfiguration = MembershipConfiguration.default
    
    
    
    
    
    
    
    
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
        
        if let existingUser = getUser(withPassId: captureDataInformation.passId) {
            
            updateVisits(for: existingUser)
        } else {
            
            handleUnrecognizedUser(with: captureDataInformation)
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
        captureLayer.discoveredDeviceHandler = { [weak self] (discoveredDevice, deviceManager) in
            self?.discoveredDeviceHandler?(discoveredDevice, deviceManager)
        }
        captureLayer.discoveryEndedHandler = { [weak self] (result, deviceManager) in
            self?.autodiscoveryEndedHandler?(result, deviceManager)
        }
        return captureLayer
    }
    
    private func handleUnrecognizedUser(with captureDataInformation: CaptureDataInformation) {
        
        switch Club.Configuration.userCreationStyle {
        case .automaticallyOnScan:
            
            createUser(with: captureDataInformation)
            
        case .withSatisfied(let condition):
            
            if condition() == true {
                createUser(with: captureDataInformation)
            }
        }
    }
}


public struct MembershipConfiguration {
    
    public enum UserCreation: Equatable {
        public static func ==(lhs: UserCreation, rhs: UserCreation) -> Bool {
            switch (lhs, rhs) {
            case (let .withSatisfied(booleanExpression1), let .withSatisfied(booleanExpression2)):
                return booleanExpression1() == booleanExpression2()
            case (.automaticallyOnScan, .automaticallyOnScan):
                return true
            default:
                return false
            }
        }
        
        /// New users are automatically created when passes are scanned
        case automaticallyOnScan
        
        /**
         New users are only created after some boolean condition is satisfied
         - Parameters:
            - condition: Completion block expected to return a boolean expression. New users will only be created if and only if this condition is true at the time passes are scanned
        */
        case withSatisfied(condition: () -> (Bool))
    }
    
    /// Enum for determining how users will be created
    /// when passes are scanned.
    public var userCreationStyle: UserCreation = .automaticallyOnScan
    
    /// Default configuration
    public static var `default`: MembershipConfiguration {
        var config = MembershipConfiguration()
        config.userCreationStyle = .automaticallyOnScan
        return config
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
        
        if let existingUser = getUser(withPassId: captureDataInformation.passId) {
            
            let error = CKError.userExistsAlready("Attempted to create a new user but one already exists: \(existingUser)")
            
            delegate?.club?(self, didReceive: error)
            
        } else {
            // This user does not exist and there is no error
            
            let user = OverridableMembershipUserClassType.init()

            user.memberId = UUID().uuidString
            user.passId = captureDataInformation.passId
            user.username = captureDataInformation.username
            
            let currentDateTimestamp = Date().timeIntervalSince1970

            user.numVisits = 1
            user.timeStampOfLastVisit = currentDateTimestamp
            user.timeStampAdded = currentDateTimestamp
            
            RealmLayer.shared.write { (realm, error) in
                if let error = error {
                    DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error writing to realm: \(error)")
                    delegate?.club?(self, didReceive: error)
                }
                
                if let realm = realm {
                    realm.add(user)
                    delegate?.club?(self, didCreateNewMembership: user)
                }
            }
        }
    }
    
    public func merge(importedUsers: [MembershipUser]) {
        
        RealmLayer.shared.write { (realm, error) in
            if let error = error {
                delegate?.club?(self, didReceive: error)
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error writing to realm: \(error)")
            }
            
            if let realm = realm {
                realm.add(importedUsers, update: .modified)
            }
        }
    }
    
    public func getUser(withMemberId memberId: String) -> MembershipUser? {
        return RealmLayer.shared.queryFor(userType: OverridableMembershipUserClassType.self, primaryKey: memberId)
    }
    
    public func getUser(withPassId passId: String) -> MembershipUser? {
        let predicate = NSPredicate(format: "\(MembershipUser.CodingKeys.passId.rawValue) = %@", passId)
        let filteredResults = RealmLayer.shared.queryForUsers(ofType: OverridableMembershipUserClassType.self,
                                          predicate: predicate)
        return filteredResults?.first
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
        RealmLayer.shared.write { (realm, error) in
            if let error = error {
                delegate?.club?(self, didReceive: error)
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error writing to realm: \(error)")
            }
            
            if let _ = realm {
                // Perform changes to user object and update in Realm
                changes()
            }
        }
    }
    
    public func deleteUser(withMemberId memberId: String) {
        if let user = getUser(withMemberId: memberId) {
            deleteUser(user)
        } else {
            
            let error = CKError.nonexistentUser("No such user exists")
            delegate?.club?(self, didReceive: error)
        }
    }
    
    public func deleteUser(withPassId passId: String) {
        if let user = getUser(withPassId: passId) {
            deleteUser(user)
        } else {
            
            let error = CKError.nonexistentUser("No such user exists")
            delegate?.club?(self, didReceive: error)
        }
    }
    
    public func deleteUser(_ user: MembershipUser) {
        
        RealmLayer.shared.write { (realm, error) in
            if let error = error {
                delegate?.club?(self, didReceive: error)
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Error writing to realm: \(error)")
            }
            
            if let realm = realm {
                realm.delete(user)
                delegate?.club?(self, didDeleteMembership: user)
            }
        }
    }
}
