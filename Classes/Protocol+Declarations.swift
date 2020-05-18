//
//  Protocol+Declarations.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import Foundation
import SKTCapture

protocol CaptureMiddlewareProtocol: class {
    
    func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice)
    
    var decodedDataFormat: CaptureMiddleware.DecodedDataParseFormat { get }
    
    func setDecodedDataParse(format: CaptureMiddleware.DecodedDataParseFormat)
    
}

protocol IdentifiableUserProtocol {
    // A unique String representing the user
    // This may either a UID or the email address (possibly gathered from Smart Pass)
    var userId: String? { get }
    
    // Name of the user. Probably the first and last name
    // (possibly gathered from Smart Pass)
    var username: String? { get }
    
    // The date that this was user was created/added
    var timeStampAdded: Double { get }
}


// Manages membership, check-in/out

protocol CaptureMembershipProtocol: CaptureMiddlewareProtocol {
    
    associatedtype userType: IdentifiableUserProtocol
    
    
        
    
    // CRUD
    
    func createUser(with decodedDataString: String)
    
    func getUser(with decodedDataString: String) -> userType?
    
    func updateUserInStorage(_ user: userType)
    
    func deleteUser(with decodedDataString: String)
    
    func deleteUser(_ user: userType)
}
