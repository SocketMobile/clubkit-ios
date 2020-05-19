//
//  CaptureMiddleware.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture

/// Default implementation for a CaptureMiddleware object that conforms to the CaptureMiddlewareProtocol
/// May be subclassed
public class CaptureMiddleware: NSObject, CaptureMiddlewareProtocol {
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    public func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) {}
    
    /// Enum for different formats by which the decodedData will be parsed
    public enum DecodedDataParseFormat: Int {
        case defaultRFID = 0
        case NDEF
    }
    
    /// Determines how the decoded data will be parsed. Can be configured.
    public private(set) var decodedDataFormat: DecodedDataParseFormat = .defaultRFID
    
    /// Sets the format by which the decoded data will be parsed.
    public func setDecodedDataParse(format: DecodedDataParseFormat) {
        self.decodedDataFormat = format
    }
}
