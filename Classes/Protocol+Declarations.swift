//
//  Protocol+Declarations.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture
import RealmSwift

// MARK: - IdentifiableUserProtocool

/// Protocol for all User objects to conform to. If creating a custom User class, the custom class must
/// conform to this protocol
public protocol IdentifiableUserProtocol: class {
    
    /// Unique identifier for this user (Often supplied within the Mobile Pass)
    var userId: String? { get }
    
    /// Username for the user (Often supplied within the Mobile Pass)
    var username: String? { get }
    
    /// Timestamp (in milliseconds since January 1, 1970) of this user's creation date
    var timeStampAdded: Double { get }
    
}





// MARK: - CaptureMiddlewareProtocol

/// Protocol for CaptureMiddleware classes. If creating a custom CaptureMiddleware class, the custom class
/// must conform to this protocol
public protocol CaptureMiddlewareProtocol: class {
    
    var capture: CaptureHelper! { get }
    
    func setCapture(instance: CaptureHelper)
    
    var numberOfFailedOpenCaptureAttempts: Int { get }
    
    /// Open the SKTCapture layer with credentials.
    /// This is required for proper use of BLE devices in the desired app.
    ///
    /// - Parameters:
    ///   - appKey: appKey String provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - appId: appId String that represents the local bundle identifier, prefixed with platform. Provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - developerId: developerId String provided during SDK registration:  [Socket Mobile Developer portal](https://www.socketmobile.com/developer/welcome)
    ///   - completion: completes with CaptureLayer result which maps success or failure of operation into a code
    func open(withAppKey appKey: String, appId: String, developerId: String, completion: ((CaptureLayerResult) -> ())?)
    
    /// Closes the SKTCapture layer
    func close(_ completion: ((CaptureLayerResult) -> ())?)
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    @discardableResult func onDecodedData(decodedData: CaptureLayerDecodedData?, device: CaptureLayerDevice) -> Error?
    
    /// Determines how the decoded data will be parsed. Can be configured.
    var decodedDataFormat: CaptureMiddleware.DecodedDataParseFormat { get }
    
    /// Sets the format by which the decoded data will be parsed.
    func setDecodedDataParse(format: CaptureMiddleware.DecodedDataParseFormat)
    
    /// Begins timer for discovering nearby BLE devices
    /// - Parameters:
    ///     -  numSeconds: The number of seconds before the discovery ends, after which the completion handler will be called
    ///     - completion: Completion block which returns all the devices that were discovered
    func startAutoDiscovery(numSeconds: Int, completion: @escaping ([DiscoveredDeviceInfo]) -> ())
    
    /// Sets the discovered device to be the favorite. Afterward, the "favorited" device
    /// will auto connect
    /// - Parameters:
    ///     - discoveredDeviceInfo: Struct containing identifiers used to set a BLE device as a favorite
    func setFavorite(discoveredDeviceInfo: DiscoveredDeviceInfo)
}






// MARK: - CaptureMembershipProtocol

/// Protocol for managing users. If creating a custom CaptureMembership class, the custom class
/// must conform to this protocol
public protocol CaptureMembershipProtocol: CaptureMiddlewareProtocol {
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    associatedtype userType: IdentifiableUserProtocol
    
    /// Defines a set of rules that dictates how Club handles user membership
    /// One such example is how Club handles scanning of user passes that have not been previously encountered.
    static var Configuration: MembershipConfiguration  { get set }
    
    // CRUD
    
    /// Creates a new User object in storage from the data within the decodedDataString
    /// - Parameters:
    ///   - captureDataInformation: Object that represents the data contained in a mobile pass, RFID card or otherwise
    func createUser(with captureDataInformation: CaptureDataInformation)
    
    /// Merges User objects that are imported from another device
    /// If an object already exists with the same primary key (user Id), the changes are merged using the values
    /// of the imported object
    /// - Parameters:
    ///   - importedUsers: Array of `MembershipUser` objects imported from another device
    func merge(importedUsers: [MembershipUser])
    
    /// Queries and returns a User object from storage matching the properties within the decodedDataString
    /// - Parameters:
    ///   - userId: Unique String (often alpha-numeric) that represents a single user
    func getUser(with userId: String) -> userType?
    
    /// Updates a User object with new properties and re-saves it in storage
    /// - Parameters:
    ///   - user: User object/class. May be subclassed
    ///   - changes: Block in which you should perform your changes to the user object
    func update(user: userType, withChanges changes: () -> ())
    
    /// Queries and deletes a User object from storage matching the properties within the decodedDataString
    /// - Parameters:
    ///   - userId: Unique String (often alpha-numeric) that represents a single user
    func deleteUser(with userId: String)
    
    /// Deletes a User object from storage
    /// - Parameters:
    ///   - user: User object/class. May be subclassed
    func deleteUser(_ user: userType)
    
}

// MARK: - ClubKitProtocol

public protocol ClubKitProtocol {
    
    /// Shared reference to ClubKit singleton
    static var shared: Club { get }
    
    /// Notifies of operations on MembershipUsers and its subclasses
    var delegate: ClubMiddlewareDelegate? { get }
    
    /// Object type for your MembershipUser subclass
    /// Use `setCustomMembershipUser(classType:)` during setup if you
    /// would like to provide your own `MembershipUser` subclass
    var OverridableMembershipUserClassType: MembershipUser.Type { get }
    
    /// Creates a a file containing all user records on this device
    /// This URL can then be exported to other devices
    /// - Parameters:
    ///   - objectType: The class type of your MembershipUser subclass. (e.g. CustomMembershipUser.self)
    ///   - fileType: The file format and extension you would like to export with
    func getExportableURLForDataSource<T: MembershipUser>(ofType objectType: T.Type, fileType: IOFileType) -> URL?
    
    /// Receives imported list of users from a file and merges with existing records
    /// - Parameters:
    ///   - objectType: The class type of your MembershipUser subclass. (e.g. CustomMembershipUser.self)
    ///   - url: The URL pointing to the imported file
    func getImportedDataSource<T: MembershipUser>(ofType objectType: T.Type, from url: URL)
    
    /// Set the delegate for CaptureMiddlewareDelegate
    /// - Parameters:
    ///   - to: The receiver of the delegate events
    @discardableResult func setDelegate(to: ClubMiddlewareDelegate) -> Club
    
    /// Set the DispatchQueue by which SKTCapture delegate functions will be invoked on
    @discardableResult func setDispatchQueue(_ queue: DispatchQueue) -> Club
    
    /// Determines whether debug messages will be logged
    /// to the DebugLogger object
    /// - Parameters:
    ///   - isActivated: Boolean value that, when set to true will save debug messages to the DebugLogger. False by default if unused
    @discardableResult func setDebugMode(isActivated: Bool) -> Club
    
    /// Provide your own custom MembershipUser class type
    /// to be used for all operations.
    /// If this function is not called, the default `MembershipUser` class will be used
    /// `classType` must be a subclass of `MembershipUser`
    @discardableResult func setCustomMembershipUser(classType: MembershipUser.Type) -> Club
    
    /// Re-assumes SKTCapture layer delegate
    func assumeCaptureDelegate()
    
    /// Resigns SKTCapture layer delegate to desired receiver
    func resignCaptureDelegate(to: CaptureHelperAllDelegate)
}

extension ClubKitProtocol where Self: Club {
    
    public func getExportableURLForDataSource<T: MembershipUser>(ofType objectType: T.Type, fileType: IOFileType) -> URL? {
        switch fileType {
        case .userList: return ExportableDataSourceContainer<T>().convertDataSourceToUserListFile()
        case .csv:      return ExportableDataSourceContainer<T>().convertDataSourceToCSVFile()
        }
    }
    
    public func getImportedDataSource<T: MembershipUser>(ofType objectType: T.Type, from url: URL) {
        // Perform parsing of imported URL on background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            if let importedUsers = ExportableDataSourceContainer<T>.importDataSource(at: url) {
                
                // Return to main thread
                DispatchQueue.main.async {
                    strongSelf.delegate?.club?(strongSelf, didReceiveImported: importedUsers)
                }
            }
        }
    }
    
    @discardableResult
    public func setDispatchQueue(_ queue: DispatchQueue) -> Club {
        capture.dispatchQueue = queue
        return self
    }
    
    @discardableResult
    public func setDebugMode(isActivated: Bool) -> Club {
        DebugLogger.shared.toggleDebug(isActivated: isActivated)
        return self
    }
    
    public func assumeCaptureDelegate() {
        capture.pushDelegate(captureLayer)
    }
    
    public func resignCaptureDelegate(to: CaptureHelperAllDelegate) {
        capture.pushDelegate(to)
    }
}







// MARK: - IOFileType

/// Represents the file type to be imported/exported
public enum IOFileType {
    case userList
    case csv
    
    var fileExtension: String {
        switch self {
        case .userList: return ClubConstants.IOFileType.userListFileExtension
        case .csv:      return ClubConstants.IOFileType.csvFileExtension
        }
    }
}










// MARK: - CKError

/// Internal errors related to scanning mobile passes, RFID cards, etc.

public enum CKError: Error {
    
    /// Attempted to create a new user with a userId of an existing user
    /// - Parameters:
    ///   - ErrorMessage: Detailed message of the error
    case userExistsAlready(String)
    
    /// Attempted to delete a user with a userId that does not match any existing user
    /// - Parameters:
    ///   - ErrorMessage: Detailed message of the error
    case nonexistentUser(String)
    
    /// DecodedData does not exist
    /// - Parameters:
    ///   - ErrorMessage: Detailed message of the error
    case nullDecodedData(String)
    
    /// UTF8 String representation of DecodedData does not exist
    /// - Parameters:
    ///   - ErrorMessage: Detailed message of the error
    case nonExistentUTF8DecodedDataString(String)
    
    
    /// The pass does not contain the expected fiels: payload number, unique identifier, payload, username
    /// - Parameters:
    ///   - ErrorMessage: Detailed message of the error
    case invalidPassInformation(String)
}






/// Typealias to refer to SKTCapture device manager without exposing SKTCapture framework
public typealias CaptureLayerDeviceManager = CaptureHelperDeviceManager
/// Typealias to refer to SKTCapture device  without exposing SKTCapture framework
public typealias CaptureLayerDevice = CaptureHelperDevice
/// Typealias to refer to SKTCapture result without exposing SKTCapture framework
public typealias CaptureLayerResult = SKTResult
/// Typealias to refer to SKTCapture decoded data without exposing SKTCapture framework
public typealias CaptureLayerDecodedData = SKTCaptureDecodedData



// MARK: - CaptureMiddlewareDelegate

/// Public optional delegate used in the CaptureMiddleware class and its subclasses.
@objc public protocol CaptureMiddlewareDelegate: class {
    
    /// Notifies the delegate that a CaptureHelper device manager is now available for use
    /// Use this to configure the manager
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - deviceManager: SKTCapture device manager
    ///   - result: CaptureLayer result which maps success or failure of operation into a code
    @objc optional func capture(_ middleware: CaptureMiddleware, didNotifyArrivalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult)
    
    /// Notifies the delegate that a CaptureHelper device manager is no longer available
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - deviceManager: SKTCapture device manager
    ///   - result: CaptureLayer result which maps success or failure of operation into a code
    @objc optional func capture(_ middleware: CaptureMiddleware, didNotifyRemovalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult)
    
    /// Notifies the delegate that a CaptureHelper device has been connected
    /// Use this to refresh UI in iOS application
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - device: SKTCapture device
    ///   - result: CaptureLayer result which maps success or failure of operation into a code
    @objc optional func capture(_ middleware: CaptureMiddleware, didNotifyArrivalFor device: CaptureLayerDevice, result: CaptureLayerResult)
    
    /// Notifies the delegate that a CaptureHelper device has been disconnected
    /// Use this to refresh UI in iOS application
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - device: SKTCapture device
    ///   - result: CaptureLayer result which maps success or failure of operation into a code
    @objc optional func capture(_ middleware: CaptureMiddleware, didNotifyRemovalFor device: CaptureLayerDevice, result: CaptureLayerResult)
    
    /// Notifies the delegate that the battery level of aa CaptureHelperDevice has changed
    /// Use this to refresh UI in iOS application
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - value: Integer value representing battery level of respective device (0-100)
    ///   - deviceManager: SKTCapture device
    @objc optional func capture(_ middleware: CaptureMiddleware, batteryLevelDidChange value: Int, for device: CaptureLayerDevice)
    
    
    /// Notifies the delegate that a CaptureHelper device has scanned some mobile pass, barcode, RFID card, etc.
    /// This may be used in concert with CaptureMiddleware.onDecodedData function
    ///
    /// Even if using CaptureMiddleware and SKTCapture simultaneously, this function will
    /// only be called once, depending on which entity is set as the Capture delegate.
    /// - Parameters:
    ///   - middleware: CaptureMiddleware object/class that invokes this delegate function
    ///   - decodedData: Defines a Capture event Decoded Data, which has a Symbology ID, Symbology Name and decoded data.
    ///   - device: SKTCapture device
    ///   - result: CaptureLayer result which maps success or failure of operation into a code
    @objc optional func capture(_ middleware: CaptureMiddleware, didReceive decodedData: CaptureLayerDecodedData?, for device: CaptureLayerDevice, withResult result: CaptureLayerResult)
    
}











// MARK: - ClubMiddlewareDelegate

/// Public optional delegate used in the Club object. Notifies of operations on MembershipUsers and its subclasses
@objc public protocol ClubMiddlewareDelegate: CaptureMiddlewareDelegate {
    
    /// Notifies the delegate of errors received during Club CaptureMiddleware operations
    /// Use this to get more information on errors
    ///
    /// - Parameters:
    ///   - clubMiddleware: Club CaptureMiddleware object/class that invokes this delegate function
    ///   - error: Error received during operation
    @objc optional func club(_ clubMiddleware: Club, didReceive error: Error)
    
    /// Notifies the delegate that a new MembershipUser object has been created
    /// Use this to show popup views, or update the UI, etc. if desired
    ///
    /// - Parameters:
    ///   - clubMiddleware: Club CaptureMiddleware object/class that invokes this delegate function
    ///   - user: MembershipUser object that has been newly created
    @objc optional func club(_ clubMiddleware: Club, didCreateNewMembership user: MembershipUser)
    
    /// Notifies the delegate that a MembershipUser object has been updated
    /// Use this to show popup views, or update the UI, etc. if desired
    ///
    /// - Parameters:
    ///   - clubMiddleware: Club CaptureMiddleware object/class that invokes this delegate function
    ///   - user: MembershipUser object that has been updated
    @objc optional func club(_ clubMiddleware: Club, didUpdateMembership user: MembershipUser)
    
    /// Notifies the delegate that a MembershipUser object has been deleted
    /// Use this to show popup views, or update the UI, etc. if desired
    ///
    /// - Parameters:
    ///   - clubMiddleware: Club CaptureMiddleware object/class that invokes this delegate function
    ///   - user: MembershipUser object that has been deleted
    @objc optional func club(_ clubMiddleware: Club, didDeleteMembership user: MembershipUser)
    
    /// Notifies the delegate that an array of `MembershipUser` objects have been imported from another device
    /// Use this to store new list of transferred data in local Realm
    ///
    /// - Parameters:
    ///   - clubMiddleware: Club CaptureMiddleware object/class that invokes this delegate function
    ///   - users: Array of imported MembershipUser objects to be stored
    @objc optional func club(_ clubMiddleware: Club, didReceiveImported users: [MembershipUser])
}












// MARK: - CaptureDataUserInformation

public protocol CaptureDataUserInformationProtocol {
    var userId: String { get }
    var username: String { get }
    var payloadNumber: String { get }
    var payload: String { get }
    
    init?(captureDataString: String)
}

/// Struct for representing the user information obtained from scanning a mobile pass, RFID card, etc.
public struct CaptureDataInformation: CaptureDataUserInformationProtocol {
    
    public let userId: String
    public let username: String
    public let payloadNumber: String
    public let payload: String
    
    // Expects a string from scanning a Mobile Pass or otherwise that
    // contains data
    public init?(captureDataString: String) {
        let components = captureDataString.components(separatedBy: "|")
        guard components.count == 4 else {
            // TODO
            // NOTE
            // This is a temporary assumption (as of 05/19/2020)
            // There are 4 fields expected in the decodedData string
            // payload number, userId, payload, name
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Unexpected capture data format: \(captureDataString). Expecting 4 fields: payload number, unique identifier, payload, username. Instead, found \(components.count) fields.")
            return nil
        }
        
        payloadNumber = components[0]
        userId = components[1]
        payload = components[2]
        username = components[3]
    }
}
