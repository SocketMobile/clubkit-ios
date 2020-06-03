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
    public var deviceManagerRemovalHandler: SKTCaptureDeviceManagerRemovalHandler?
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

