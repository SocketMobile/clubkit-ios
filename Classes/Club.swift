//
//  Club.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture
import RealmSwift
import SKTCapture

public final class Club: CaptureMiddleware, CaptureMembershipProtocol {
    
    // MARK: - Variables
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    /// May be overriden by providing your own custom MembershipUser class type
    /// in the `setCustomMembershipUser(classType:)` function during initialization
    public typealias userType = MembershipUser
    
    /// Gives developer the opportunity to use their own MembershipUser subclasses
    /// Will override the default MembershipUser class that is used in typical operations
    private var OverridableMembershipUserClassType: MembershipUser.Type = MembershipUser.self
    
    public static let shared = Club(capture: CaptureHelper.sharedInstance)
    
    private weak var delegate: ClubMiddlewareDelegate?
    
    private var numberOfFailedOpenCaptureAttempts: Int = 0
    
    public private(set) weak var capture: CaptureHelper!
    
    private var captureLayer: SKTCaptureLayer!
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers (PRIVATE / Singleton)
    
    private init(capture: CaptureHelper) {
        super.init()
        self.capture = capture
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
        
        let captureDataInformation = CaptureDataInformation(captureDataString: captureDataString)
        
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
    
}















// MARK: - Setup Functions

extension Club {
    
    /// Set the delegate for CaptureMiddlewareDelegate
    @discardableResult
    public func setDelegate(to: ClubMiddlewareDelegate) -> Club {
        self.delegate = to
        return self
    }
    
    /// Set the DispatchQueue by which SKTCapture delegate functions will be invoked on
    @discardableResult
    public func setDispatchQueue(_ queue: DispatchQueue) -> Club {
        capture.dispatchQueue = queue
        return self
    }
    
    /// Determines whether debug messages will be logged
    /// to the DebugLogger object
    /// - Parameters:
    ///   - isActivated: Boolean value that, when set to true will save debug messages to the DebugLogger. False by default if unused
    @discardableResult
    public func setDebugMode(isActivated: Bool) -> Club {
        UserDefaults.standard.set(isActivated, forKey: ClubConstants.DebugMode.debugModeUserDefaultsKey)
        return self
    }
    
    /// Provide your own custom MembershipUser class type
    /// to be used for all operations.
    /// If this function is not called, the default `MembershipUser` class will be used
    /// `classType` must be a subclass of `MembershipUser`
    @discardableResult
    public func setCustomMembershipUser(classType: MembershipUser.Type) -> Club {
        OverridableMembershipUserClassType = classType
        return self
    }
    
    /// Open the SKTCapture layer with credentials.
    /// This is required for proper use of BLE devices in the desired app.
    ///
    /// - Parameters:
    ///   - appKey: appKey String provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - appId: appId String that represents the local bundle identifier, prefixed with platform. Provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - developerId: developerId String provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - completion: completes with CaptureLayer result which maps success or failure of operation into a code
    public func open(withAppKey appKey: String, appId: String, developerId: String, completion: ((CaptureLayerResult) -> ())? = nil) {
        
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = appKey
        AppInfo.appID = appId
        AppInfo.developerID = developerId
        
        capture.openWithAppInfo(AppInfo) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DebugLogger.shared.addDebugMessage("Result of Capture initialization: \(result.rawValue)")
            
            if result == CaptureLayerResult.E_NOERROR {
                
                strongSelf.captureLayer = strongSelf.setupCaptureLayer()
                completion?(result)
                
            } else {

                if strongSelf.numberOfFailedOpenCaptureAttempts == 2 {

                    // Display an alert to the user to restart the app
                    // if attempts to open capture have failed twice

                    // What should we do here in case of this issue?
                    // This is a SKTCapture-specific error
                    completion?(result)
                    
                } else {

                    // Attempt to open capture again
                    DebugLogger.shared.addDebugMessage("\n--- Failed to open capture. attempting again...\n")
                    strongSelf.numberOfFailedOpenCaptureAttempts += 1
                    strongSelf.open(withAppKey: appKey, appId: appId, developerId: developerId)
                }
            }
        }
    }
    
    /// Closes the SKTCapture layer
    public func close(_ completion: ((CaptureLayerResult) -> ())?) {
        capture.closeWithCompletionHandler({ (result) in
            completion?(result)
        })
    }
    
    private func setupCaptureLayer() -> SKTCaptureLayer {
        
        let captureLayer = SKTCaptureLayer()
        capture.pushDelegate(captureLayer)
        
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
    
    /// Re-assumes SKTCapture layer delegate
    public func assumeCaptureDelegate() {
        capture.pushDelegate(captureLayer)
    }
    
    /// Resigns SKTCapture layer delegate to desired receiver
    public func resignCaptureDelegate(to: CaptureHelperAllDelegate) {
        capture.pushDelegate(to)
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
    
    public func getUser(with userId: String) -> MembershipUser? {
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: OverridableMembershipUserClassType.self, forPrimaryKey: userId)
            return user
        } catch let error {
            delegate?.club?(self, didReceive: error)
            DebugLogger.shared.addDebugMessage("Error getting user: \(error)")
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






















// MARK: - MembershipUserCollection

/// A wrapper for RealmSwift-related query on MemberShipUser
/// without exposing the RealmSwift framework
public typealias MembershipUserChanges<T: MembershipUser> = RealmCollectionChange<Results<T>>

/// Maintains self-updating collection of MembershipUsers
public class MembershipUserCollection<T: MembershipUser>: NSObject {
    
    /// Results collection of MembershipUsers
    public private(set) var users: Results<T>!
    
    private var usersToken: NotificationToken?
    
    public override init() {
        super.init()
    }
    
    /// Observes changes to MembershipUser records
    ///
    /// - Parameters:
    ///   - completion: Provides all changes such as insertions, deletions, modifications and initial result of the collection of MembershipUser records. Use this to update UI (such as UITableView and UICollectionViews) with updated records.
    open func observeAllRecords(_ completion: @escaping (MembershipUserChanges<T>) -> ()) {
        do {
            let realm = try Realm()
            users = realm.objects(T.self)
            
            usersToken = users.observe({ (changes) in
                completion(changes)
            })
        } catch let error {
            DebugLogger.shared.addDebugMessage("Error getting realm reference: \(error)")
        }
    }
    
}
