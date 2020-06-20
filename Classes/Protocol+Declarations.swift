//
//  Protocol+Declarations.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture

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
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    @discardableResult func onDecodedData(decodedData: CaptureLayerDecodedData?, device: CaptureLayerDevice) -> Error?
    
    /// Determines how the decoded data will be parsed. Can be configured.
    var decodedDataFormat: CaptureMiddleware.DecodedDataParseFormat { get }
    
    /// Sets the format by which the decoded data will be parsed.
    func setDecodedDataParse(format: CaptureMiddleware.DecodedDataParseFormat)
    
}






// MARK: - CaptureMembershipProtocol

/// Protocol for managing users. If creating a custom CaptureMembership class, the custom class
/// must conform to this protocol
public protocol CaptureMembershipProtocol: CaptureMiddlewareProtocol {
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    associatedtype userType: IdentifiableUserProtocol
    
    
    
    // CRUD
    
    /// Creates a new User object in storage from the data within the decodedDataString
    /// - Parameters:
    ///   - captureDataInformation: Object that represents the data contained in a mobile pass, RFID card or otherwise
    func createUser(with captureDataInformation: CaptureDataInformation)
    
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
            DebugLogger.shared.addDebugMessage("Unexpected capture data format: \(captureDataString). Expecting 4 fields: payload number, unique identifier, payload, username. Instead, found \(components.count) fields.")
            return nil
        }
        
        payloadNumber = components[0]
        userId = components[1]
        payload = components[2]
        username = components[3]
    }
}
