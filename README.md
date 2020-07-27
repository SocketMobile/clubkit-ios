# ClubKit

[![CI Status](https://img.shields.io/travis/Chrishon/ClubKit.svg?style=flat)](https://travis-ci.org/Chrishon/ClubKit)
[![Version](https://img.shields.io/cocoapods/v/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)
[![License](https://img.shields.io/cocoapods/l/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)
[![Platform](https://img.shields.io/cocoapods/p/ClubKit.svg?style=flat)](https://cocoapods.org/pods/ClubKit)


## Usage

Under the hood, ClubKit is an umbrella for our iOS Capture SDK. So naturally, you need to provide credentials to get started. 

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

## Documentation



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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
