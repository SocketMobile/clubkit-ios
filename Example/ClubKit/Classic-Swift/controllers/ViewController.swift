//
//  ViewController.swift
//  ClubKit
//
//  Created by Chrishon on 05/18/2020.
//  Copyright (c) 2020 Chrishon. All rights reserved.
//

import UIKit
import ClubKit

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private let cellReuseIdentifier = "cellReuseIdentifier"
    
    private var devices: [CaptureLayerDevice] = []
    
    
    
    // MARK: - UI Elements
    
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
            .setDispatchQueue(DispatchQueue.main)
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
        navigationItem.rightBarButtonItem = {
           let btn = UIBarButtonItem(title: "Menu",
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(pushUserListController))
            btn.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
            return btn
        }()
        view.backgroundColor = UIColor.systemBackground
        navigationController?.navigationBar.tintColor = Constants.ClassicSwiftConstants.AppTheme.primaryColor
        
        [connectedDevicesLabel,
         collectionView,
         captureDataModalView].forEach { (view) in
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
        
    }
    
    @objc private func pushUserListController() {
        navigationController?.pushViewController(UserListViewController(), animated: true)
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










//MARK: - CaptureMiddlewareDelegate

extension ViewController: CaptureMiddlewareDelegate {
    
    func capture(_ middleware: CaptureMiddleware, didNotifyArrivalForManager deviceManager: CaptureLayerDeviceManager, result: CaptureLayerResult) {
        
        deviceManager.dispatchQueue = DispatchQueue.main

        // By default, the favorites is set to ""
        deviceManager.getFavoriteDevicesWithCompletionHandler { (result, favorite) in
            if result == CaptureLayerResult.E_NOERROR {
                if let favorite = favorite, favorite == "" {
                    deviceManager.setFavoriteDevices("*") { (result) in

                    }
                }
            }
        }
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
        
        if let error = Club.shared.onDecodedData(decodedData: decodedData, device: device) {
            print("Error reading decoded data: \(error.localizedDescription)")
        }

        if let decodedData = decodedData, let stringFromData = decodedData.stringFromDecodedData() {
            print("tag id raw value: \(decodedData.dataSourceID.rawValue)")
            print("tag id: \(decodedData.dataSourceID)")
            print("data source name: \(String(describing: decodedData.dataSourceName))")
            print("decoded data: \(stringFromData)")

            captureDataModalView.updateUI(withDecodedData: stringFromData)
        }
    }
    
}
