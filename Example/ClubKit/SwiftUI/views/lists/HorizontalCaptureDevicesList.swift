//
//  HorizontalCaptureDevicesList.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI
import SKTCapture

struct HorizontalCaptureDevicesList: View {
    
    let captureHelperDeviceWrappers: [CaptureHelperDeviceWrapper]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(captureHelperDeviceWrappers, id: \.id) { (deviceWrapper) in
                    
                    NavigationLink(destination: CaptureHelperDeviceDetailView(deviceWrapper: deviceWrapper)) {
                        ConnectedDeviceHorizontalCell(device: deviceWrapper.captureHelperDevice)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200, alignment: .leading)
        .padding(.leading, 10)
    }
}

struct ConnectedDeviceHorizontalCell: View {
    
    let device: CaptureHelperDevice
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack (alignment: .center) {
            CircleImageView(imageURL: "", imageFrameDimension: 60)
            .padding(8)
            
            VStack (alignment: .leading) {
                Text("Device Name:")
                    .foregroundColor(.primary)
                    .font(.headline)
                Text(device.deviceInfo.name ?? "NO NAME")
                    .foregroundColor(.primary)
                    .font(.subheadline)
                    .lineLimit(nil)
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(Constants.SwiftUIConstants.getBackgroundColor(from: colorScheme))
        .cornerRadius(Constants.UIFormat.roundedCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UIFormat.roundedCornerRadius)
                .stroke(Constants.SwiftUIConstants.AppTheme.primaryColor, lineWidth: Constants.UIFormat.roundedBorderWidth)
        )
            .shadow(radius: Constants.UIFormat.shadowRadius)
    }
}

