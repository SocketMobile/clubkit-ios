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
    
    internal var captureLayer: SKTCaptureLayer!
    
    public private(set) var remainingOpenCaptureRetries: Int = 2
    
    /// Enum for different formats by which the decodedData will be parsed
    public enum DecodedDataParseFormat: Int {
        case defaultRFID = 0
        case NDEF
    }
    
    /// Determines how the decoded data will be parsed. Can be configured.
    public private(set) var decodedDataFormat: DecodedDataParseFormat = .defaultRFID
    
    
    internal var discoveredDeviceHandler: SKTCaptureDiscoveredDeviceHandler?
    internal var autodiscoveryEndedHandler: SKTCaptureDiscoveryEndedHandler?
    
    public func setCapture(instance: CaptureHelper) {
        self.capture = instance
    }
    
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
                if strongSelf.remainingOpenCaptureRetries == 0 {

                    // Display an alert to the user to restart the app
                    // if attempts to open capture have failed twice

                    // What should we do here in case of this issue?
                    // This is a SKTCapture-specific error
                    completion?(result)
                    
                } else {

                    // Attempt to open capture again
                    DebugLogger.shared.addDebugMessage("\(String(describing: type(of: strongSelf))) - Failed to open capture. attempting again...\n")
                    strongSelf.remainingOpenCaptureRetries -= 1
                    strongSelf.open(withAppKey: appKey, appId: appId, developerId: developerId, completion: completion)
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
    
    public func startAutoDiscovery(numSeconds: Int, completion: @escaping ([DiscoveredDeviceInfo]) -> ()) {
        
        guard let deviceManager = capture.getDeviceManagers().first else {
            completion([])
            return
        }
        
        let timeout = (numSeconds * 1000)
        
        var discoveredDevices: [DiscoveredDeviceInfo] = []
        
        deviceManager.setFavoriteDevices("") { [weak self] (result) in
            if result != .E_NOERROR {
                let debugMessage = "\(String(describing: type(of: self))) - Error with setting device favorite. Error code: \(result.rawValue)"
                DebugLogger.shared.addDebugMessage(debugMessage)
            }
            
            deviceManager.startDiscoveryWithTimeout(timeout, withCompletionHandler: { (result) in
                if result != .E_NOERROR {
                    let debugMessage = "\(String(describing: type(of: self))) - Error with starting auto discovery. Error code: \(result.rawValue)"
                    DebugLogger.shared.addDebugMessage(debugMessage)
                    completion([])
                }
            })
            
            self?.discoveredDeviceHandler = { (discoveredDevice, _) in
                discoveredDevices.append(discoveredDevice)
            }
            
            self?.autodiscoveryEndedHandler = { (result, _) in
                self?.discoveredDeviceHandler = nil
                self?.autodiscoveryEndedHandler = nil
                completion(discoveredDevices)
            }
        }
    }
    
    public func setFavorite(discoveredDeviceInfo discoveredDevice: DiscoveredDeviceInfo) {
        
        guard let deviceManager = capture.getDeviceManagers().first else {
            return
        }
        
        deviceManager.setFavoriteDevices(discoveredDevice.identifierUUID) { (result) in
            if result != .E_NOERROR {
                let debugMessage = "\(String(describing: type(of: self))) - Error with setting device favorite. Error code: \(result.rawValue)"
                DebugLogger.shared.addDebugMessage(debugMessage)
            }
        }
    }
}





/// Struct containing identifiers used to set a BLE device as a favorite
/// If using auto discovery to discover nearby devices,
/// use the `identifierUUID` to set the device as the favorite
public struct DiscoveredDeviceInfo: Equatable {
    
    public static func ==(lhs: DiscoveredDeviceInfo, rhs: DiscoveredDeviceInfo) -> Bool {
        return lhs.identifierUUID == rhs.identifierUUID
    }
    
    public let identifierUUID: String
    public let deviceName: String
    public let serviceUUID: String
}
