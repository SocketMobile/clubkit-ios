//
//  CaptureLayer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/29/20.
//

import SKTCapture

internal typealias SKTCaptureErrorResultHandler = (CaptureLayerResult) -> ()
internal typealias SKTCaptureDeviceManagerArrivalHandler = (CaptureLayerDeviceManager, CaptureLayerResult) -> ()
internal typealias SKTCaptureDeviceManagerRemovalHandler = (CaptureLayerDeviceManager, CaptureLayerResult) -> ()
internal typealias SKTCaptureDeviceArrivalHandler = (CaptureLayerDevice, CaptureLayerResult) -> ()
internal typealias SKTCaptureDeviceRemovalHandler = (CaptureLayerDevice, CaptureLayerResult) -> ()
internal typealias SKTCaptureDataHandler = (CaptureLayerDecodedData?, CaptureLayerDevice, CaptureLayerResult) -> ()
internal typealias SKTCaptureBatteryLevelChangeHandler = (Int, CaptureLayerDevice) -> ()
internal typealias SKTCaptureDiscoveredDeviceHandler = (DiscoveredDeviceInfo, CaptureLayerDeviceManager) -> ()
internal typealias SKTCaptureDiscoveryEndedHandler = (SKTResult, CaptureLayerDeviceManager) -> ()

/// Manages events from `SKTCapture` and notifies receiver
internal class SKTCaptureLayer:
    NSObject,
    CaptureHelperErrorDelegate,
    CaptureHelperDeviceManagerDiscoveryDelegate,
    CaptureHelperDeviceManagerPresenceDelegate,
    CaptureHelperDevicePresenceDelegate,
    CaptureHelperDevicePowerDelegate,
    CaptureHelperDeviceDecodedDataDelegate
{
    
    internal var errorEventHandler: SKTCaptureErrorResultHandler?
    internal var deviceManagerArrivalHandler: SKTCaptureDeviceManagerArrivalHandler?
    internal var deviceManagerRemovalHandler: SKTCaptureDeviceManagerRemovalHandler?
    internal var deviceArrivalHandler: SKTCaptureDeviceArrivalHandler?
    internal var deviceRemovalHandler: SKTCaptureDeviceRemovalHandler?
    internal var captureDataHandler: SKTCaptureDataHandler?
    internal var batteryLevelChangeHandler: SKTCaptureBatteryLevelChangeHandler?
    internal var discoveredDeviceHandler: SKTCaptureDiscoveredDeviceHandler?
    internal var discoveryEndedHandler: SKTCaptureDiscoveryEndedHandler?
    
    override init() {
        super.init()
    }
    
    
    
    
    
    
    func didReceiveError(_ error: SKTResult) {
        
        errorEventHandler?(error)
    }
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        
        deviceManagerArrivalHandler?(device, result)

    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
    
        deviceManagerRemovalHandler?(device, result)
        
    }
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
    
        deviceArrivalHandler?(device, result)
        
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
    
        deviceRemovalHandler?(device, result)
        
    }
    
    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
        
    }
    
    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
        
        batteryLevelChangeHandler?(batteryLevel, device)
        
    }
    
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
       
        captureDataHandler?(decodedData, device, result)
        
    }
    
    func didDiscoverDevice(_ device: String, fromDeviceManager deviceManager: CaptureHelperDeviceManager) {
        
        guard let data = device.data(using: String.Encoding.utf8) else {
            return
        }

        do {
            
            guard let deviceInfo = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                return
            }
            
            let deviceInfoIdentifierUUIDKey = "identifierUUID"
            let deviceInfoNameKey = "name"
            let deviceInfoServiceUUIDKey = "serviceUUID"
                
            guard
                let identifiierUUID = deviceInfo[deviceInfoIdentifierUUIDKey] as? String,
                let deviceName = deviceInfo[deviceInfoNameKey] as? String,
                let serviceUUID = deviceInfo[deviceInfoServiceUUIDKey] as? String
                else {
                return
            }
            
            let discoveredDevice = DiscoveredDeviceInfo(identifierUUID: identifiierUUID,
                                                        deviceName: deviceName,
                                                        serviceUUID: serviceUUID)
            
            discoveredDeviceHandler?(discoveredDevice, deviceManager)
            
        } catch let error {
            print("Error getting device info: \(error.localizedDescription)")
        }
    }
    
    func didEndDiscoveryWithResult(_ result: SKTResult, fromDeviceManager deviceManager: CaptureHelperDeviceManager) {
        discoveryEndedHandler?(result, deviceManager)
    }
}

