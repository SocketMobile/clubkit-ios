//
//  ViewController.swift
//  ClubKit
//
//  Created by Chrishon on 05/18/2020.
//  Copyright (c) 2020 Chrishon. All rights reserved.
//

import UIKit
import ClubKit

class AutoDiscoveryLoadingView: UIView {
    
    let activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
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
        isHidden = true
        backgroundColor = UIColor.white
        
        addSubview(activityIndicator)
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    override var isHidden: Bool {
        didSet {
            if isHidden {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }
}

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private let cellReuseIdentifier = "cellReuseIdentifier"
    
    private var devices: [CaptureLayerDevice] = []
    
    
    
    // MARK: - UI Elements
    
    private lazy var menuButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Menu",
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(pushUserListController))
        btn.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        return btn
    }()
    
    private lazy var autoDiscoveryButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "AutoDiscovery",
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(beginAutoDiscovery))
        btn.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        return btn
    }()
    
    private lazy var resetFavoriteButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "ResetFavorite",
                                 style: UIBarButtonItemStyle.plain,
                                 target: self,
                                 action: #selector(resetFavoriteDevice))
        btn.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        return btn
    }()
    
    private let autoDiscoveryLoadingView = AutoDiscoveryLoadingView()
    private let autoDiscoveryResultsView = AutoDiscoveryResultsView()
    
    private var connectedDevicesLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Connected devices: 0"
        
        return lbl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.systemBackground
        cv.alwaysBounceHorizontal = true
        return cv
    }()
    
    private let captureDataModalView = CaptureDataModalView()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUIElements()
        setupClub()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupClub() {
        let appKey =        "MCwCFCXpDCyuA6LzdgGJAk01jdbjZa2wAhRI3zDMlVcwi+4pIU0SRE7P6JP7Pw=="
        let appID =         "ios:com.socketmobile.ClubKit-Example"
        let developerID =   "bb57d8e1-f911-47ba-b510-693be162686a"
        
        Club.shared.setDelegate(to: self)
            .setCustomMembershipUser(classType: CustomMembershipUser.self)
            .setDispatchQueue(DispatchQueue.main)
            .setDebugMode(isActivated: true)
            .open(withAppKey:   appKey,
                  appId:        appID,
                  developerId:  developerID,
                  completion: { (result) in
                    
                    if result != CaptureLayerResult.E_NOERROR {
                        // Open failed due to internal error.
                        // Display an alert to the user suggesting to restart the app
                        // or perform some other action.
                    }
             })
        
    }
    
    private func setupUIElements() {
        
        self.title = "Membership Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [menuButton, autoDiscoveryButton, resetFavoriteButton]
        view.backgroundColor = UIColor.systemBackground
        navigationController?.navigationBar.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        
        [connectedDevicesLabel,
         collectionView,
         captureDataModalView,
         autoDiscoveryLoadingView,
         autoDiscoveryResultsView].forEach { (view) in
            self.view.addSubview(view)
        }
        
        
        
        
        connectedDevicesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        connectedDevicesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        connectedDevicesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        connectedDevicesLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        collectionView.topAnchor.constraint(equalTo: connectedDevicesLabel.bottomAnchor, constant: 8).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.register(DeviceCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
        
        captureDataModalView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        
        captureDataModalView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        captureDataModalView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        captureDataModalView.heightAnchor.constraint(equalToConstant: 300.0).isActive = true
        
        
        [autoDiscoveryLoadingView, autoDiscoveryResultsView].forEach { (v) in
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    @objc private func pushUserListController() {
        navigationController?.pushViewController(UserListViewController(), animated: true)
    }
    
    @objc private func beginAutoDiscovery() {
        autoDiscoveryLoadingView.isHidden = false
        Club.shared.startAutoDiscovery(numSeconds: 2) { [weak self] (discoveredDevices) in
            self?.autoDiscoveryLoadingView.isHidden = true
            self?.autoDiscoveryResultsView.add(discoveredDevices: discoveredDevices)
        }
    }
    
    @objc private func resetFavoriteDevice() {
        Club.shared.resetFavorite()
    }

}






// MARK: - UICollectionView delegation

extension ViewController:
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? DeviceCollectionViewCell
        
        let device = devices[indexPath.item]
        cell?.setup(with: device.deviceInfo)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = 140.0
        let height: CGFloat = 140.0
        
        return CGSize(width: width, height: height)
        
    }
    
}










// MARK: - CaptureMiddlewareDelegate

extension ViewController: ClubMiddlewareDelegate {
    
    func club(_ clubMiddleware: Club, didCreateNewMembership user: MembershipUser) {
        print("did create new membership user: \(user)")
    }
    
    func club(_ clubMiddleware: Club, didUpdateMembership user: MembershipUser) {
        print("did update membership user: \(user)")
    }
    
    func club(_ clubMiddleware: Club, didDeleteMembership user: MembershipUser) {
        print("did delete membership user: \(user)")
    }
    
    func capture(_ middleware: CaptureMiddleware, didNotifyArrivalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult) {
        
        deviceManager.dispatchQueue = DispatchQueue.main
    }
    
    func capture(_ middleware: CaptureMiddleware, didNotifyRemovalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult) {
        
    }
    
    func capture(_ middleware: CaptureMiddleware, didNotifyArrivalFor device: CaptureLayerDevice, result: CaptureLayerResult) {
        
        devices.append(device)
        connectedDevicesLabel.text = "Connected devices: \(devices.count)"
        collectionView.reloadData()
    }
    
    func capture(_ middleware: CaptureMiddleware, didNotifyRemovalFor device: CaptureLayerDevice, result: CaptureLayerResult) {
        
        if let index = devices.firstIndex(of: device) {
            devices.remove(at: index)
            connectedDevicesLabel.text = "Connected devices: \(devices.count)"
        }
        collectionView.reloadData()
    }
    
    func capture(_ middleware: CaptureMiddleware, batteryLevelDidChange value: Int, for device: CaptureLayerDevice) {
        
    }
    
    func capture(_ middleware: CaptureMiddleware, didReceive decodedData: CaptureLayerDecodedData?, for device: CaptureLayerDevice, withResult result: CaptureLayerResult) {
        
        if let decodedData = decodedData, let stringFromData = decodedData.stringFromDecodedData() {
            
            // NOTE
            // Assumes the decodedData is in UTF8 format
            
            print("tag id raw value: \(decodedData.dataSourceID.rawValue)")
            print("tag id: \(decodedData.dataSourceID)")
            print("data source name: \(String(describing: decodedData.dataSourceName))")
            print("decoded data: \(stringFromData)")

            captureDataModalView.updateUI(withDecodedData: stringFromData)
        }
    }
    
    func club(_ clubMiddleware: Club, didReceiveImported users: [MembershipUser]) {
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertStyle = UIAlertController.Style.alert
        }
        
        let alertController = UIAlertController(title: "Import",
                                                message: "Received \(users.count) users to import. Would you like to save them?",
                                                preferredStyle: alertStyle)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (_) in
            Club.shared.merge(importedUsers: users)
        }
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) { (_) in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
