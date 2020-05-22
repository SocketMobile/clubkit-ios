//
//  CircularImageView.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI

struct CircleImageView: View {
    let imageURL: String
    let imageFrameDimension: CGFloat
    
    init(imageURL: String, imageFrameDimension: CGFloat) {
        self.imageURL = imageURL
        self.imageFrameDimension = imageFrameDimension
    }
    
    var body: some View {
        Image(imageURL.isEmpty ? "apple" : imageURL)
        .resizable()
        .renderingMode(.original)
        .clipShape(Circle())
            .overlay(Circle().stroke(Constants.SwiftUIConstants.AppTheme.primaryColor, lineWidth: Constants.SwiftUIConstants.UIFormat.roundedBorderWidth))
        .frame(width: imageFrameDimension, height: imageFrameDimension)
    }
    
}
