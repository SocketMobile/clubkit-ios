//
//  CaptureDataModalView.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 5/26/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SKTCapture
import ClubKit

class CaptureDataModalView: UIView {
    
    private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.text = "Waiting for user to scan their pass..."
        return lbl
    }()
    
    private var secondaryLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private var captureDataTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = true
        return tv
    }()
    
    
    
    
    
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setupUIElements() {
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        backgroundColor = UIColor.systemBackground
        layer.borderColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor.cgColor
        layer.borderWidth = Constants.UIFormat.roundedBorderWidth
        layer.cornerRadius = Constants.UIFormat.roundedCornerRadius
        
        [titleLabel,
         secondaryLabel,
         captureDataTextView].forEach { (view) in
            self.addSubview(view)
        }
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        secondaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        secondaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        secondaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        secondaryLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        captureDataTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        captureDataTextView.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 8).isActive = true
        captureDataTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        captureDataTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
    }
    
    public func updateUI(withDecodedData decodedDataString: String?) {
        guard let decodedDataString = decodedDataString else {
            return
        }
        
        guard let captureDataInformation = CaptureDataInformation(captureDataString: decodedDataString) else {
            return
        }
        
        let user = Club.shared.getUser(withPassId: captureDataInformation.passId)
        guard let username = user?.username else {
            return
        }
        titleLabel.text = "Hello, \(username)"
        
        
        guard let numberOfVisits = user?.numVisits else {
            return
        }
        if numberOfVisits == 1 {
            secondaryLabel.text = "\(String(describing: user?.username ?? "[USERNAME]")) has visited for the first time!!!!"
        } else {
            secondaryLabel.text = "\(String(describing: user?.username ?? "[USERNAME]")) has visited [BUSINESS NAME] \(numberOfVisits) times"
        }
        
        
        
        captureDataTextView.text = decodedDataString
    }
}
