//
//  ContentView.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI
import SKTCapture

struct ContentView: View {
    
    @EnvironmentObject var dataCaptureLayer: SKTCaptureDeviceViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            SwiftUICaptureDemoView()
            .navigationBarItems(trailing:
                NavigationLink(destination: CoreDataListView(),
                               label: {
                                Text("Menu")
                                    .foregroundColor(Constants.SwiftUIConstants.AppTheme.primaryColor)
                })
            )
                .background(Constants.SwiftUIConstants.getBackgroundColor(from: colorScheme))
        }.accentColor(Constants.SwiftUIConstants.AppTheme.primaryColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SKTCaptureDeviceViewModel())
    }
}





















// MARK: - SwiftUICaptureDemoView

struct SwiftUICaptureDemoView: View {
    
    @EnvironmentObject var captureDeviceViewModel: SKTCaptureDeviceViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Connected devices: \(captureDeviceViewModel.captureHelperDeviceWrappers.count)")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
            
            HorizontalCaptureDevicesList(captureHelperDeviceWrappers: captureDeviceViewModel.captureHelperDeviceWrappers)
            
//                VerticalCaptureDevicesList(captureHelperDeviceWrappers: captureDeviceViewModel.captureHelperDeviceWrappers)
            
            CaptureDataView(captureDataWrapper: captureDeviceViewModel.captureDataWrapper)
                .cornerRadius(Constants.UIFormat.roundedCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UIFormat.roundedCornerRadius)
                        .stroke(Constants.SwiftUIConstants.AppTheme.primaryColor, lineWidth: Constants.UIFormat.roundedBorderWidth)
                )
                .shadow(radius: Constants.UIFormat.shadowRadius)
        }
        .navigationBarTitle(Text("Membership Demo"))
    }
}

struct SwiftUICaptureDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUICaptureDemoView()
    }
}









// MARK: - Device Detail View

struct CaptureHelperDeviceDetailView: View {
    
    let deviceWrapper: CaptureHelperDeviceWrapper
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(deviceWrapper.captureHelperDevice.deviceInfo.name ?? "NO NAME")
                .font(.headline)
                .underline()
                .lineLimit(nil)
                .padding(10)
                .foregroundColor(Color.primary)
            Text(deviceWrapper.captureHelperDevice.deviceInfo.guid ?? "NO GUID")
                .font(.subheadline)
                .lineLimit(nil)
                .padding(10)
                .foregroundColor(Color.primary)
        }.background(Constants.SwiftUIConstants.AppTheme.primaryColor)
            .cornerRadius(Constants.UIFormat.roundedCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UIFormat.roundedCornerRadius)
                .stroke(Constants.SwiftUIConstants.AppTheme.primaryColor, lineWidth: Constants.UIFormat.roundedBorderWidth)
        )
            .shadow(radius: Constants.UIFormat.shadowRadius)
    }
}
