//
//  ViewController.swift
//  ClubKit
//
//  Created by Chrishon on 05/18/2020.
//  Copyright (c) 2020 Chrishon. All rights reserved.
//

import UIKit
import ClubKit
import SKTCapture
import RealmSwift

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private let cellReuseIdentifier = "cellReuseIdentifier"
    
    private let capture = CaptureHelper.sharedInstance
    
    
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
    
    private let decodedDataView = DecodedDataModalView()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUIElements()
        setupCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
         decodedDataView].forEach { (view) in
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
        
        
        
        decodedDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        
        decodedDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        decodedDataView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        decodedDataView.heightAnchor.constraint(equalToConstant: 300.0).isActive = true
        
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
        return capture.getDevices().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? DeviceCollectionViewCell
        
        let device = capture.getDevices()[indexPath.item]
        cell?.setup(with: device.deviceInfo)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = 140.0
        let height: CGFloat = 140.0
        
        return CGSize(width: width, height: height)
        
    }
    
}
















// MARK: - Capture delegation

extension ViewController: CaptureHelperDeviceManagerPresenceDelegate,
    CaptureHelperDevicePresenceDelegate,
    CaptureHelperDeviceManagerDiscoveryDelegate,
    CaptureHelperDeviceDecodedDataDelegate {
    
    
    private func setupCapture() {
        let AppInfo = SKTAppInfo();
        AppInfo.appKey="MCwCFCXpDCyuA6LzdgGJAk01jdbjZa2wAhRI3zDMlVcwi+4pIU0SRE7P6JP7Pw==";
        AppInfo.appID="ios:com.socketmobile.ClubKit-Example";
        AppInfo.developerID="bb57d8e1-f911-47ba-b510-693be162686a";
        // open Capture Helper only once in the application
        
        capture.dispatchQueue = DispatchQueue.main
        capture.pushDelegate(self)
        capture.openWithAppInfo(AppInfo, withCompletionHandler: { (result: SKTResult) in
            print("Result of Capture initialization: \(result.rawValue)")
        })
    }
    
    
    
    
    // CaptureHelperDeviceManagerPresenceDelegate
    
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        
        device.dispatchQueue = DispatchQueue.main
        
        // By default, the favorites is set to ""
        device.getFavoriteDevicesWithCompletionHandler { (result, favorite) in
            if result == SKTResult.E_NOERROR {
                if let favorite = favorite {
                    print("device favorite: \(favorite)")
                    if favorite == "" {
                        device.setFavoriteDevices("*") { (result) in
                            
                        }
                    }
                }
            }
        }
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
        
    }
    
    
    
    
    // CaptureHelperDevicePresenceDelegate
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        print("capture device arrived")
        
        connectedDevicesLabel.text = "Connected devices: \(capture.getDevices().count)"
        collectionView.reloadData()
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        
        connectedDevicesLabel.text = "Connected devices: \(capture.getDevices().count)"
        collectionView.reloadData()
    }

    
    
    
    // CaptureHelperDeviceManagerDiscoveryDelegate
    
    func didDiscoverDevice(_ device: String, fromDeviceManager deviceManager: CaptureHelperDeviceManager) {
      
    }
    
    func didEndDiscoveryWithResult(_ result: SKTResult, fromDeviceManager deviceManager: CaptureHelperDeviceManager){
        
    }
    
    
    
    



    // CaptureHelperDeviceDecodedDataDelegate
    
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        
        if let error = Club.shared.onDecodedData(decodedData: decodedData, device: device) {
            print("Error reading decoded data: \(error.localizedDescription)")
        }
        
        if let decodedData = decodedData, let stringFromData = decodedData.stringFromDecodedData() {
            print("tag id raw value: \(decodedData.dataSourceID.rawValue)")
            print("tag id: \(decodedData.dataSourceID)")
            print("data source name: \(String(describing: decodedData.dataSourceName))")
            print("decoded data: \(stringFromData)")
            
            decodedDataView.updateUI(withDecodedData: stringFromData)
        }
    }
}
