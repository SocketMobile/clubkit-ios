//
//  DeviceCollectionViewCell.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 5/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SKTCapture



class DeviceCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variables
    
    
    
    
    
    // MARK: - UI Elements
    
    private var deviceNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.preferredMaxLayoutWidth = 125.0
        return lbl
    }()
    
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    // MARK: - Functions
    
    private func setupUIElements() {
        contentView.addSubview(deviceNameLabel)
        
        contentView.layer.borderColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor.cgColor
        contentView.layer.borderWidth = Constants.UIFormat.roundedBorderWidth
        
        deviceNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        deviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        deviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        deviceNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    public func setup(with deviceInfo: SKTCaptureDeviceInfo) {
        
        if let deviceFriendlyName = deviceInfo.name {
            deviceNameLabel.text = deviceFriendlyName
        }
    }
}

