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

By default, ClubKit offers an out-of-the-box user class: `MembershipUser`

This provides 5 basic values for each user record:

- `userId`: A string that uniquely identifiers the user record.
- `username`: A string for the user's name. 
- `timeStampAdded`: The time interval (since UTC Jan 1 1970) of the user record's creation date
- `numVisits`: Number of times the user has scanned their mobile pass/RFID card.
- `timeStampOfLastVisit`: The time interval (since UTC Jan 1 1970) of the last time the user has scanned their mobile pass/RFID card.


The `MembershipUser` superclass encodes and decodes its variables (and their values) into and from Data. This allows the record to be synced across different devices.

Using the example of `CustomMembershipUser` which, aside from the 5 basic values, adds a 6th value: Email Address:

```swift
@objcMembers class CustomMembershipUser: MembershipUser {

}
```
Use the modifier `@objcMembers` in the class declaration to signify that we will be using Objective C objects in our subclass.
You will <b>NOT</b> be writing Objective C code here. It is merely a requirement for observing `dynamic` variables



### Step 1/3

- First, define a variable you would like to observe in this record. As noted before, in this example, we will add an Email Address to this User class.
- Then, define an enum which conforms to `String`, `CodingKey` and `CaseIterable`. Then define cases for all of your variables
<b>NOTE: The case name must match the name of the variable it represents. camelCase, lowercased, UPPERCASED, etc. It must match exactly</b>M

```swift
dynamic var userEmailAddress: String?

enum CodingKeys: String, CodingKey, CaseIterable {
    case userEmailAddress
}

```

### Step 2/3,
- Next, override an aptly named function called `variableNamesAsStrings() -> [String]` and return all the case values you created in Step 1, plus the superclass values.
This allows your subclass to be synced between different devices. More on that [later](#syncing-users-between-devices)

```swift

override class func variableNamesAsStrings() -> [String] {

let superclassVariableNames: [String] = super.variableNamesAsStrings()
    
    // Using CaseIterable, map through all CodingKeys enum and return its rawValue
    let mySubclassVariableNames: [String] = CodingKeys.allCases.map { $0.rawValue }
    
    return superclassVariableNames + mySubclassVariableNames
}

```

### Step 3
Finally, provide implementation to the overriden [Encodabe](https://developer.apple.com/documentation/swift/encodable)  and  [Decodable](https://developer.apple.com/documentation/swift/decodable) functions:

```swift

// Encodable
public override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    
    // Create container to encode your variables
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    // TRY to encode your variable using the key that matches
    try container.encode(emailAddress, forKey: .emailAddress)
    
    // ... Other variables if necessary
}

// Decodable
public required init(from decoder: Decoder) throws  {
    try super.init(from: decoder)
    
    // Create container, again, but this time for decoding your variables
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // TRY to decode the data into your original variable type and value
    emailAddress = try container.decode(String.self, forKey: .emailAddress)
}

```
For encoding variables, it uses the matching Key you created in the `CodingKeys` enum, and encodes the variable to Data.

For decoding, its reversed. The Data in the container which matches the specific key is decoded to its original variable.


### Final Result

After following the 3 steps, your subclass should look like this

```swift
@objcMembers class CustomMembershipUser: MembershipUser {
    
    dynamic var emailAddress: String? = "Some Email address"
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case emailAddress
    }
    
    override class func variableNamesAsStrings() -> [String] {
        let superclassNames = super.variableNamesAsStrings()
        return superclassNames + CodingKeys.allCases.map { $0.rawValue }
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
