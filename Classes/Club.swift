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
    
    
    
    
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    public override func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) -> Error? {
        
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
    
    @discardableResult
    public func setDelegate(to: CaptureMiddlewareDelegate) -> Club {
        self.delegate = to
        return self
    }
    
    @discardableResult
    public func setDispatchQueue(_ queue: DispatchQueue) -> Club {
        capture.dispatchQueue = queue
        return self
    }
    
    public func open(withAppKey appKey: String, appId: String, developerId: String, completion: ((SKTResult) -> ())? = nil) {
        
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = appKey
        AppInfo.appID = appId
        AppInfo.developerID = developerId
        
        capture.openWithAppInfo(AppInfo) { [weak self] (result) in
            guard let strongSelf = self else { return }
            NSLog("Result of Capture initialization: \(result.rawValue)")
            
            if result == SKTResult.E_NOERROR {
                
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
                    NSLog("\n--- Failed to open capture. attempting again...\n")
                    strongSelf.numberOfFailedOpenCaptureAttempts += 1
                    strongSelf.open(withAppKey: appKey, appId: appId, developerId: developerId)
                }
            }
        }
    }
    
    public func close(_ completion: ((Bool) -> ())?) {
        capture.closeWithCompletionHandler({ (result) in
            if result == SKTResult.E_NOERROR {
                completion?(true)
            } else {
                
                // What should we do here in case of this issue?
                // This is a SKTCapture-specific error
                completion?(false)
            }
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
    
    public func assumeCaptureDelegate() {
        capture.pushDelegate(captureLayer)
    }
    
    public func resignCaptureDelegate(to: CaptureHelperAllDelegate) {
        capture.pushDelegate(to)
    }
    
}















// MARK: - API

extension Club {
    
    /// Creates a new User object in storage from the data within the decodedDataString
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
    
    /// Queries and returns a User object from storage matching the properties within the decodedDataString
    public func getUser(with userId: String) -> MembershipUser? {
        
        do {
            let realm = try Realm()
            let user = realm.object(ofType: MembershipUser.self, forPrimaryKey: userId)
            return user
        } catch let error {
            NSLog("Error getting user: \(error)")
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






















// MARK: - MembershipUserCollection
/// A wrapper for RealmSwift-related query on MemberShipUser
/// without exposing the RealmSwift framework

public typealias MembershipUserChanges = RealmCollectionChange<Results<MembershipUser>>

public class MembershipUserCollection: NSObject {
    
    public private(set) var users: Results<MembershipUser>!
    
    private var usersToken: NotificationToken?
    
    public override init() {
        super.init()
    }
    
    open func observeAllRecords(_ completion: @escaping (MembershipUserChanges) -> ()) {
        do {
            let realm = try Realm()
            users = realm.objects(MembershipUser.self)
            
            usersToken = users.observe({ (changes) in
                completion(changes)
            })
        } catch let error {
            NSLog("Error getting realm reference: \(error)")
        }
    }
    
}
