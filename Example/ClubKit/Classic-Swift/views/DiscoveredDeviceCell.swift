//
//  DiscoveredDeviceCell.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 8/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DiscoveredDeviceCell: UICollectionViewCell {
    
    
    // MARK: - UI Elements
    
    private var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        v.layer.cornerRadius = 7
        v.layer.borderColor = UIColor.gray.cgColor
        v.backgroundColor = .systemGroupedBackground
        return v
    }()
    
    public var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.backgroundColor = .systemGroupedBackground
        return img
    }()
    
    public var deviceTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.gray
        lbl.textAlignment = .center
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        return lbl
    }()
    
    
    
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    // MARK: - Functions
    
    private func setupUIElements() {
        [containerView, imageView, deviceTitleLabel].forEach { contentView.addSubview($0) }
        
        
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        let imageViewDimension: CGFloat = 60.0
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        imageView.layer.cornerRadius = imageViewDimension / 2
        
        deviceTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        deviceTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        deviceTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        deviceTitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
    }
}
