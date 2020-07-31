# ClubKit

[![CI Status](https://img.shields.io/travis/Chrishon/ClubKit.svg?style=flat)](https://travis-ci.org/Chrishon/ClubKit)
[![Version](https://img.shields.io/cocoapods/v/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)
[![License](https://img.shields.io/cocoapods/l/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)
[![Platform](https://img.shields.io/cocoapods/p/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)

ClubKit provides Membership/Loyalty functionality when paired with our Socket Mobile S550 NFC reader.
Developers can use the S550 NFC reader to scan appropriate Mobile Pass and/or RFID cards carried by end users to update
their local record. Examples include maintaining number of visits, time of last visit and much more when configured.

* [Usage](#usage)
* [Documentation](#documentation)
    * [Subclassing User class](#subclassing-membership-user)
    * [Displaying User Records](#displaying-user-list)
    * [Syncing User Records Between Devices](#syncing-users-between-devices)
    * [Delegate Events](#receiving-delegate-events)
* [Example App](#example-app)
* [Requirements](#requirements)
* [Installation](#installation)

<a name="usage"/>

## Usage

Under the hood, ClubKit is an umbrella for our iOS Capture SDK. So naturally, you need to provide credentials to get started. 

You may provide your own [subclass of `MembershipUser`](#subclassing-membership-user) class, to maintain more than the default information
on end users

```swift

override func viewDidLoad() {
    super.viewDidLoad()

    setupClub()
}

private func setupClub() {
    let appKey =        <Your App Key>
    let appId =         <Your App ID>
    let developerId =   <Your Developer ID>
    
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
```

<a name="documentation" />

## Documentation

<a name="subclassing-membership-user"/>

### Creating User class

```swift
@objcMembers class CustomMembershipUser: MembershipUser {
    
    @objc dynamic var emailAddress: String? = "Some Email address"
    
    override class func variableNamesAsStrings() -> [String] {
        let superclassNames = super.variableNamesAsStrings()
        return superclassNames + CodingKeys.allCases.map { $0.rawValue }
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case emailAddress
    }
    
    required init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws  {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emailAddress = try container.decode(String.self, forKey: .emailAddress)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(emailAddress, forKey: .emailAddress)
    }
}
```

<a name="displaying-user-list"/>

### Displaying User Records

Displaying user records

```swift
private let usersCollection = MembershipUserCollection<CustomMembershipUser>()
```

<a name="syncing-users-between-devices"/>

### Syncing User Records Between Devices

<a name="receiving-delegate-events"/>

### Delegate Events




<a name="example-app" />

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<a name="requirements" />

## Requirements

<ul>
<li><p>Xcode 7.3</p></li>
<li><p>iOS 9.3</p></li>
</ul>

<a name="installation" />

## Installation

ClubKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ClubKit'
```

## Author

Chrishon, chrishon@socketmobile.com

## License

ClubKit is available under the MIT license. See the LICENSE file for more info.
