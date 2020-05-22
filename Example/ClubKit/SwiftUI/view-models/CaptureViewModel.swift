//
//  CaptureViewModel.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SKTCapture
import ClubKit

// MARK: - Wrappers

struct CaptureHelperDeviceWrapper: Identifiable {
    var id: String {
        return captureHelperDevice.deviceInfo.guid ?? UUID().uuidString
    }
    let captureHelperDevice: CaptureHelperDevice
}



struct DecodedDataWrapper {
    public private(set) var decodedData: SKTCaptureDecodedData?
    public private(set) var device: CaptureHelperDevice?
    
    init() {}
    
    mutating func update(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) {
        self.decodedData = decodedData
        self.device = device
    }
}










// MARK: - Capture View Model

class SKTCaptureDeviceViewModel: ObservableObject,
    CaptureHelperDeviceManagerPresenceDelegate,
    CaptureHelperDevicePresenceDelegate,
    CaptureHelperDeviceManagerDiscoveryDelegate,
    CaptureHelperDeviceDecodedDataDelegate {
    
    private let capture = CaptureHelper.sharedInstance
    
    @Published var captureHelperDeviceWrappers: [CaptureHelperDeviceWrapper] = []
    
    @Published var decodedDataWrapper = DecodedDataWrapper()
    

    init() {
        setupCapture()
    }
    
    private func setupCapture() {
        let AppInfo = SKTAppInfo();
        AppInfo.appKey="MCwCFCXpDCyuA6LzdgGJAk01jdbjZa2wAhRI3zDMlVcwi+4pIU0SRE7P6JP7Pw==";
        AppInfo.appID="ios:com.socketmobile.ClubKit-Example";
        AppInfo.developerID="bb57d8e1-f911-47ba-b510-693be162686a";
        // open Capture Helper only once in the application
        
        capture.dispatchQueue = DispatchQueue.main
        capture.pushDelegate(self)
        capture.openWithAppInfo(AppInfo, withCompletionHandler: { (result: SKTResult) in
            print("Result of Capture initialization: \(result.rawValue)")
        })
    }
    
    
    
    
    // CaptureHelperDeviceManagerPresenceDelegate
    
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
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        
    }
    
    
    
    
    // CaptureHelperDevicePresenceDelegate
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("capture device arrived")
        let deviceWrapper = CaptureHelperDeviceWrapper(captureHelperDevice: device)
        self.captureHelperDeviceWrappers.append(deviceWrapper)
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        
        guard let arrayElementIndex = self.captureHelperDeviceWrappers.firstIndex(where: { (deviceWrapper) -> Bool in
            return deviceWrapper.captureHelperDevice == device
        }) else {
            return
        }
        
        self.captureHelperDeviceWrappers.remove(at: Int(arrayElementIndex))
    }

    
    
    
    // CaptureHelperDeviceManagerDiscoveryDelegate
    
    func didDiscoverDevice(_ device: String, fromDeviceManager deviceManager: CaptureHelperDeviceManager) {
      
    }
    
    func didEndDiscoveryWithResult(_ result: SKTResult, fromDeviceManager deviceManager: CaptureHelperDeviceManager){
        
    }
    
    
    
    



    // CaptureHelperDeviceDecodedDataDelegate
    
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        
        Club.shared.onDecodedData(decodedData: decodedData, device: device)
        decodedDataWrapper.update(decodedData: decodedData, device: device)

        if let decodedData = decodedData, let stringFromData = decodedData.stringFromDecodedData() {
            print("tag id raw value: \(decodedData.dataSourceID.rawValue)")
            print("tag id: \(decodedData.dataSourceID)")
            print("data source name: \(String(describing: decodedData.dataSourceName))")
            print("decoded data: \(stringFromData)")
        }
    }
}
