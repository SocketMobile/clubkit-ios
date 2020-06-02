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
    public typealias userType = MembershipUser
    
    public static let shared = Club(capture: CaptureHelper.sharedInstance)
    
    private weak var delegate: CaptureMiddlewareDelegate?
    
    private var numberOfFailedOpenCaptureAttempts: Int = 0
    
    public private(set) weak var capture: CaptureHelper!
    
    private var captureLayer: SKTCaptureLayer!
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers (PRIVATE / Singleton)
    
    private init(capture: CaptureHelper) {
        super.init()
        self.capture = capture
    }
    
    
    
    
    
    public override func onDecodedData(decodedData: CaptureLayerDecodedData?, device: CaptureLayerDevice) -> Error? {
        
        guard
            let decodedData = decodedData,
            let captureDataString = decodedData.stringFromDecodedData()
            else {
                let error = CKError.nullDecodedDataString("The decoded data string is nil")
                return error
        }
        
        let captureDataInformation = CaptureDataInformation(captureDataString: captureDataString)
        
        if let existingUser = getUser(with: captureDataInformation.userId) {
            
            return updateUserInStorage(existingUser)
        } else {
            // This is a new user
            return createUser(with: captureDataInformation)
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
    
}















// MARK: - Setup Functions

extension Club {
    
    /// Set the delegate for CaptureMiddlewareDelegate
    @discardableResult
    public func setDelegate(to: CaptureMiddlewareDelegate) -> Club {
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
    
    public func createUser(with captureDataInformation: CaptureDataInformation) -> Error? {
        
        if let existingUser = getUser(with: captureDataInformation.userId) {
            
            let error = CKError.userExistsAlready("Attempted to create a new user but one exists with this userId: \(String(describing: existingUser.userId)) and username: \(String(describing: existingUser.username))")
            return error
            
        } else {
            // This user does not exist and there is no error
            
            let user = MembershipUser()

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
                }
            } catch let error {
                return error
            }
        }
        
        return nil
    }
    
    public func getUser(with userId: String) -> MembershipUser? {
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: MembershipUser.self, forPrimaryKey: userId)
            return user
        } catch let error {
            DebugLogger.shared.addDebugMessage("Error getting user: \(error)")
        }
        
        return nil
    }
    
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
    
    public func deleteUser(with userId: String) -> Error? {
        if let user = getUser(with: userId) {
            return deleteUser(user)
        }
        
        let error = CKError.nonexistentUser("No such user exists")
        return error
    }
    
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






















// MARK: - MembershipUserCollection

/// A wrapper for RealmSwift-related query on MemberShipUser
/// without exposing the RealmSwift framework
public typealias MembershipUserChanges = RealmCollectionChange<Results<MembershipUser>>

/// Maintains self-updating collection of MembershipUsers
public class MembershipUserCollection: NSObject {
    
    /// Results collection of MembershipUsers
    public private(set) var users: Results<MembershipUser>!
    
    private var usersToken: NotificationToken?
    
    public override init() {
        super.init()
    }
    
    /// Observes changes to MembershipUser records
    ///
    /// - Parameters:
    ///   - completion: Provides all changes such as insertions, deletions, modifications and initial result of the collection of MembershipUser records. Use this to update UI (such as UITableView and UICollectionViews) with updated records.
    open func observeAllRecords(_ completion: @escaping (MembershipUserChanges) -> ()) {
        do {
            let realm = try Realm()
            users = realm.objects(MembershipUser.self)
            
            usersToken = users.observe({ (changes) in
                completion(changes)
            })
        } catch let error {
            DebugLogger.shared.addDebugMessage("Error getting realm reference: \(error)")
        }
    }
    
}
