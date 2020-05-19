//
//  Protocol+Declarations.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture

/// Protocol for all User objects to conform to. If creating a custom User class, the custom class must
/// conform to this protocol
protocol IdentifiableUserProtocol: class {
    
    /// Unique identifier for this user (Often supplied within the Mobile Pass)
    var userId: String? { get }
    
    /// Username for the user (Often supplied within the Mobile Pass)
    var username: String? { get }
    
    /// Timestamp (in milliseconds since January 1, 1970) of this user's creation date
    var timeStampAdded: Double { get }
    
}





/// Protocol for CaptureMiddleware classes. If creating a custom CaptureMiddleware class, the custom class
/// must conform to this protocol
protocol CaptureMiddlewareProtocol: class {
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice)
    
    /// Determines how the decoded data will be parsed. Can be configured.
    var decodedDataFormat: CaptureMiddleware.DecodedDataParseFormat { get }
    
    /// Sets the format by which the decoded data will be parsed.
    func setDecodedDataParse(format: CaptureMiddleware.DecodedDataParseFormat)
    
}




/// Protocol for managing users. If creating a custom CaptureMembership class, the custom class
/// must conform to this protocol
protocol CaptureMembershipProtocol: CaptureMiddlewareProtocol {
    
    /// Associated type which will be used as arguments in the API
    /// Custom User objects may be used only if they conform to this protocol
    associatedtype userType: IdentifiableUserProtocol
    
    
        
    
    // CRUD
    
    /// Creates a new User object in storage from the data within the decodedDataString
    func createUser(with decodedDataString: String)
    
    /// Queries and returns a User object from storage matching the properties within the decodedDataString
    func getUser(with decodedDataString: String) -> userType?
    
    /// Updates a User object with new properties and re-saves it in storage
    func updateUserInStorage(_ user: userType)
    
    /// Queries and deletes a User object from storage matching the properties within the decodedDataString
    func deleteUser(with decodedDataString: String)
    
    /// Deletes a User object from storage
    func deleteUser(_ user: userType)
    
    /// Parses a decodedDataString and returns a dictionary of the embedded values
    func parseDecodedData(_ decodedDataString: String) -> [String: String]
}
