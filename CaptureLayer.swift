//
//  CaptureLayer.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/29/20.
//

import SKTCapture

internal typealias SKTCaptureErrorResultHandler = (SKTResult) -> ()
internal typealias SKTCaptureDeviceManagerArrivalHandler = (CaptureHelperDeviceManager, SKTResult) -> ()
internal typealias SKTCaptureDeviceManagerRemovalHandler = (CaptureHelperDeviceManager, SKTResult) -> ()
internal typealias SKTCaptureDeviceArrivalHandler = (CaptureHelperDevice, SKTResult) -> ()
internal typealias SKTCaptureDeviceRemovalHandler = (CaptureHelperDevice, SKTResult) -> ()
internal typealias SKTCaptureDataHandler = (SKTCaptureDecodedData?, CaptureHelperDevice, SKTResult) -> ()
internal typealias SKTCaptureBatteryLevelChangeHandler = (Int, CaptureHelperDevice) -> ()



internal class SKTCaptureLayer:
    NSObject,
    CaptureHelperErrorDelegate,
    CaptureHelperDeviceManagerPresenceDelegate,
    CaptureHelperDevicePresenceDelegate,
    CaptureHelperDevicePowerDelegate,
    CaptureHelperDeviceDecodedDataDelegate
{
    
    public var errorEventHandler: SKTCaptureErrorResultHandler?
    public var deviceManagerArrivalHandler: SKTCaptureDeviceManagerArrivalHandler?
    public var deviceManagerRemovalHandler: SKTCaptureDeviceRemovalHandler?
    public var deviceArrivalHandler: SKTCaptureDeviceArrivalHandler?
    public var deviceRemovalHandler: SKTCaptureDeviceRemovalHandler?
    public var captureDataHandler: SKTCaptureDataHandler?
    public var batteryLevelChangeHandler: SKTCaptureBatteryLevelChangeHandler?
    
    
    override init() {
        super.init()
    }
    
    
    
    
    
    
    func didReceiveError(_ error: SKTResult) {
        
        errorEventHandler?(error)
    }
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        device.dispatchQueue = DispatchQueue.main

        // By default, the favorites is set to ""
        device.getFavoriteDevicesWithCompletionHandler { (result, favorite) in
            if result == SKTResult.E_NOERROR {
                if let favorite = favorite {
                    print("device favorite: \(favorite)")
                    if favorite == "" {
                        device.setFavoriteDevices("*") { (result) in

                        }
                    }
                }
            }
        }
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
    
}

