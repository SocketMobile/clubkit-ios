//
//  AutoDiscoveryResultsView.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 8/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ClubKit

class AutoDiscoveryResultsView: UIView {
    
    // MARK: - Variables
    
    private let cellReuseIdentifier: String = "deviceCell"
    private let headerReuseIdentifier: String = "headerView"
    public var devicesFromDiscovery: [DiscoveredDeviceInfo] = []
    
    
    
    
    
    
    
    // MARK: - UI Elements
    
    private var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.allowsSelection = true
        return cv
    }()
    
    private lazy var footerDismissButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Dismiss", for: .normal)
        btn.backgroundColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(dismissAnimationView), for: .touchUpInside)
        return btn
    }()
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Functions
    private func setupUIElements() {
        
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        
        [collectionView, footerDismissButton].forEach { containerView.addSubview($0) }
        
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.register(DiscoveredDeviceCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        footerDismissButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        footerDismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        footerDismissButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        footerDismissButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }

    public func add(discoveredDevices: [DiscoveredDeviceInfo]) {
        devicesFromDiscovery.append(contentsOf: discoveredDevices)
        self.isHidden = false
        collectionView.reloadData()
    }
    
    public func addNewDiscoveredDevice(_ device: DiscoveredDeviceInfo) {
        guard devicesFromDiscovery.contains(device) == false else { return }
        
        if self.alpha == 0.0 || self.isHidden == true {
            self.alpha = 1.0
            self.isHidden = false
        }
        
        collectionView.performBatchUpdates({
            devicesFromDiscovery.append(device)
            let indexPath = IndexPath(item: devicesFromDiscovery.count - 1, section: 0)
            collectionView.insertItems(at: [indexPath])
        }, completion: { (completed) in
            if completed {
                
            }
        })
    }
    
    @objc private func dismissAnimationView() {
        let animationDuration: TimeInterval = 0.7
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.isHidden = true
            self.resetAutoDiscoveryView()
        }
    }
    
    public func resetAutoDiscoveryView() {
        devicesFromDiscovery.removeAll()
        collectionView.reloadData()
    }
}







// MARK: - UICollectionView delegate and datasource

extension AutoDiscoveryResultsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if devicesFromDiscovery.count > 0 {
            collectionView.restore()
            return devicesFromDiscovery.count
        } else {
            collectionView.setEmptyMessage("Could not find any nearby devices. Make sure devices are turned on and in range")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DiscoveredDeviceCell?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? DiscoveredDeviceCell
        
        let device = devicesFromDiscovery[indexPath.item]
        cell?.deviceTitleLabel.text = device.deviceName
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width / 2) - 1
        let height: CGFloat = 250.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleDidSelectForDevice(at: indexPath)
    }
    
    private func handleDidSelectForDevice(at indexPath: IndexPath) {
    
        let discoveredDeviceInfo = devicesFromDiscovery[indexPath.item]
        
        Club.shared.setFavorite(discoveredDeviceInfo: discoveredDeviceInfo)
        
        devicesFromDiscovery.removeAll()
        collectionView.reloadData()
        
        self.isHidden = true
    }
}







extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.boldSystemFont(ofSize: 28)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
