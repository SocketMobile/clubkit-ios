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
    
    public private(set) weak var capture: CaptureHelper!
    
    public func setCapture(instance: CaptureHelper) {
        self.capture = instance
    }
    
    internal var captureLayer: SKTCaptureLayer!
    
    public private(set) var numberOfFailedOpenCaptureAttempts: Int = 0
    
    public func open(withAppKey appKey: String, appId: String, developerId: String, completion: ((CaptureLayerResult) -> ())? = nil) {
        
        let AppInfo = SKTAppInfo()
        AppInfo.appKey = appKey
        AppInfo.appID = appId
        AppInfo.developerID = developerId
        
        capture.openWithAppInfo(AppInfo) { [weak self] (result) in
            guard let strongSelf = self else { return }
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: strongSelf))) - Result of Capture initialization: \(result.rawValue)")
            
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
                    DebugLogger.shared.addDebugMessage("\(String(describing: type(of: strongSelf))) - \n--- Failed to open capture. attempting again...\n")
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
    
    internal func setupCaptureLayer() -> SKTCaptureLayer {
        fatalError("Must be overriden by subclass")
    }
    
    /// Accepts decoded data from a BLE device which can be used to
    /// manage users if the data is from a Mobile Pass
    /// - Parameters:
    ///   - decodedData: Defines a Capture event Decoded Data, which has a Symbology ID, Symbology Name and decoded data.
    ///   - device: SKTCapture device
    public func onDecodedData(decodedData: CaptureLayerDecodedData?, device: CaptureLayerDevice) -> Error? {
        return nil
    }
    
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
    
    internal static func generateError(localizedString: String, comment: String? = nil, domain: String, code: Int? = nil) -> NSError {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: NSLocalizedString(localizedString, comment: comment ?? "")
        ]
        return NSError(domain: domain, code: code ?? 0, userInfo: userInfo)
    }
}
