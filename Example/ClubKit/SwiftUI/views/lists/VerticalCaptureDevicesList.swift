//
//  VerticalCaptureDevicesList.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI
import SKTCapture

struct VerticalCaptureDevicesList: View {
    
    let captureHelperDeviceWrappers: [CaptureHelperDeviceWrapper]
    
    var body: some View {
        List {
            ForEach(captureHelperDeviceWrappers, id: \.id) { (deviceWrapper) in

                NavigationLink(destination: CaptureHelperDeviceDetailView(deviceWrapper: deviceWrapper)) {
                    ConnectedDeviceVerticalCell(device: deviceWrapper.captureHelperDevice)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

            }
        }
    }
}

struct ConnectedDeviceVerticalCell: View {
    
    let device: CaptureHelperDevice
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            CircleImageView(imageURL: "", imageFrameDimension: 60)
            .padding(8)
            
            VStack (alignment: .leading) {
                Text("Device Name:").font(.headline)
                Text(device.deviceInfo.name ?? "NO NAME")
                    .font(.subheadline)
                    .padding(8)
                    .lineLimit(nil)
            }
           
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        .background(Constants.SwiftUIConstants.getBackgroundColor(from: colorScheme))
        .padding(8)
    }
}
