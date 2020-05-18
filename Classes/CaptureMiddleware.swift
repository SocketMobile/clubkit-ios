//
//  CaptureMiddleware.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 5/18/20.
//

import SKTCapture

class CaptureMiddleware: NSObject, CaptureMiddlewareProtocol {
    
    func onDecodedData(decodedData: SKTCaptureDecodedData?, device: CaptureHelperDevice) {
         
    }
    
    public private(set) var decodedDataFormat: DecodedDataParseFormat = .defaultRFID
    
    func setDecodedDataParse(format: DecodedDataParseFormat) {
        self.decodedDataFormat = format
    }
    
    enum DecodedDataParseFormat: Int {
        case defaultRFID = 0
        case NDEF
    }
    
}
