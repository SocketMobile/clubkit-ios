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

## Creating User class

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
    // More code coming
}
```
Use the modifier `@objcMembers` in the class declaration to signify that the class will be using Objective C objects in our subclass.
You will <b>NOT</b> be writing Objective C code here. It is merely a requirement for observing `dynamic` variables



### Step 1/3

- First, define a variable you would like to observe in this record. As noted before, in this example, you will add an Email Address to this User class.
- Then, define an enum which conforms to `String`, `CodingKey` and `CaseIterable`. Then define cases for all of your variables
<b>NOTE: The case name must match the name of the variable it represents.</b> camelCase, lowercased, UPPERCASED, etc. It must match exactly

```swift
@objcMembers class CustomMembershipUser: MembershipUser {

    // Step 1/3
    dynamic var userEmailAddress: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case userEmailAddress
    }
    
    // More code coming
}

```

### Step 2/3
- Next, override an aptly named function called `variableNamesAsStrings() -> [String]` and return all the case values you created in Step 1, plus the superclass values.
This allows your subclass to be synced between different devices. More on that [later](#syncing-users-between-devices)

```swift

@objcMembers class CustomMembershipUser: MembershipUser {

    // Step 1/3
    dynamic var userEmailAddress: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case userEmailAddress
    }
    
    // Step 2/3
    override class func variableNamesAsStrings() -> [String] {

        let superclassVariableNames: [String] = super.variableNamesAsStrings()
        
        // Using CaseIterable, map through all CodingKeys enum and return its rawValue
        let mySubclassVariableNames: [String] = CodingKeys.allCases.map { $0.rawValue }
        
        return superclassVariableNames + mySubclassVariableNames
    }
    
    // More code coming
}

```

### Step 3
Finally, provide implementation to the overriden [Encodabe](https://developer.apple.com/documentation/swift/encodable)  and  [Decodable](https://developer.apple.com/documentation/swift/decodable) functions:

```swift

@objcMembers class CustomMembershipUser: MembershipUser {

    // Step 1/3
    dynamic var userEmailAddress: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case userEmailAddress
    }
    
    // Step 2/3
    override class func variableNamesAsStrings() -> [String] {

        let superclassVariableNames: [String] = super.variableNamesAsStrings()
        
        // Using CaseIterable, map through all CodingKeys enum and return its rawValue
        let mySubclassVariableNames: [String] = CodingKeys.allCases.map { $0.rawValue }
        
        return superclassVariableNames + mySubclassVariableNames
    }
    
    // Step 3/3
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

}

```
For encoding variables, it uses the matching Key you created in the `CodingKeys` enum, and encodes the variable to Data.
For decoding, its reversed. The Data in the container which matches the specific key is decoded to its original variable.

<a name="displaying-user-list"/>

## Displaying User Records

Using the `MembershipUserCollection` you can display user records in a UITableView or UICollectionView.
It accepts a generic parameter in its initializer. Pass in your custom membership user class:

```swift
private let usersCollection = MembershipUserCollection<CustomMembershipUser>()
```



### Step 1/2

First, you need to begin observing changes to user records.
Changes include new additions, updates and deletions.
You can observe or stop observing changes for user records like so:

```swift

var tableView: UITableView...

private let usersCollection = MembershipUserCollection<CustomMembershipUser>()

// ...

private func observeChanges() {
    
    usersCollection.observeAllRecords({ [weak self] (changes: MembershipUserChanges) in
        switch changes {
        case .initial(_):
            
            // Reload tableView with initial data once
            self?.tableView.reloadData()
            
        case let .update(_, deletions, insertions, modifications):
            self?.tableView.performBatchUpdates({
            
                // Reload rows for updated user records
                self?.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                
                // Insert newly created records
                self?.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                
                // Delete rows for records that have been deleted
                self?.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                
            }, completion: { (completed: Bool) in
                self?.tableView.reloadData()
            })
            break
        case let .error(error):
        
            // Handle error...
        
        }
        
    })
}

private func stopObserving() {
    // Will stop observing changes.
    // Call on viewWillDisappear, etc.
    userCollection.stopObserving()
}
```

### Step 2/2

Next, implement the usual `UITableViewDelegate` and `UITableViewDataSource` functions to display the user records:

```swift

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        if let user = usersCollection.user(at: indexPath.item) {
            
            // Configure your cell with all of the data in this user record
            
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = usersCollection.user(at: indexPath.item) {
            // Perform action with selected user
        }
    }
}

```

<a name="syncing-users-between-devices"/>

## Syncing User Records Between Devices

Syncing user records between devices is as simple as airdropping a file containing user records between the two.
Using the function below, you can generate a file containing the locally stored user records and export that file to wherever necessary

```swift
func getExportableURLForDataSource<T: MembershipUser>(ofType objectType: T.Type, fileType: IOFileType) -> URL?
```

`objectType` will be the `CustomMembershipUser` class or any other MembershipUser subclass

`IOFileType` provides two kinds of files:

- UserList
- CSV

The UserList file should only be used between two applications using ClubKit. It may be difficult opening it in other environments
The CSV file (comma separated values) can be exported to other environments however.

### Step 1/3 (Exporting)

```swift
if let exportableURL = Club.shared.getExportableURLForDataSource(ofType: CustomMembershipUser.self, fileType: .userList) {
    // Show UIActivityViewController with exportableURL
    
    let activityItems: [Any] = [
        exportableURL
    ]
    
    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    
    present(activityController, animated: true, completion: nil)
}
```

### Step 2/3 (Importing)

Importing requires that the application "catches" incoming URLs and decodes user records from the URL

For pre-iOS 13.0 applications, implement the function below in `AppDelegate` to handle incoming URLs:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    Club.shared.getImportedDataSource(ofType: CustomMembershipUser.self, from: url)
    
    return true
}
```

For applications that support iOS 13.0 and onward, implement the function below in `SceneDelegate`:

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    
    if let url = URLContexts.first?.url {
    
        Club.shared.getImportedDataSource(ofType: CustomMembershipUser.self, from: url)
    
    }
}
```

### Step 3/3 (Info.plist)

Lastly, you need to configure your application to import and export this custom exportable URL from Step 1. 
To do so, you will need to add entries to your `Info.plist` file that let the application know how to handle the
custom file types that ClubKit provides for exporting user records.

The simplest method would be to follow these steps:
- "Right+Click" on your `Info.plist` file
- `Open as->`
- `Source code`
- Then paste these entries in between the `<dict>` tags

```swift
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeIconFiles</key>
        <array/>
        <key>CFBundleTypeName</key>
        <string>Membership User List Document</string>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>LSHandlerRank</key>
        <string>Owner</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.socketmobile.MemberPass.MembershipUserListDocument</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeIconFiles</key>
        <array/>
        <key>CFBundleTypeName</key>
        <string>Membership User CSV Document</string>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>LSHandlerRank</key>
        <string>Owner</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.socketmobile.MemberPass.MembershipUserCSVDocument</string>
        </array>
    </dict>
</array>

<key>LSSupportsOpeningDocumentsInPlace</key>
<false/>

<key>UISupportsDocumentBrowser</key>
<false/>

<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.data</string>
        </array>
        <key>UTTypeDescription</key>
        <string>Membership User List Document</string>
        <key>UTTypeIconFiles</key>
        <array/>
        <key>UTTypeIdentifier</key>
        <string>com.socketmobile.MemberPass.MembershipUserListDocument</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>MUSRL</string>
                <string>musrl</string>
            </array>
        </dict>
    </dict>
    <dict>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.data</string>
        </array>
        <key>UTTypeDescription</key>
        <string>Membership User CSV Document</string>
        <key>UTTypeIconFiles</key>
        <array/>
        <key>UTTypeIdentifier</key>
        <string>com.socketmobile.MemberPass.MembershipUserCSVDocument</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>MUCSV</string>
                <string>mucsv</string>
            </array>
        </dict>
    </dict>
</array>
```

The next step is to implement a ClubKit [delegate](#import-users-delegate) which provides the opportunity to approve or deny merging the incoming user records with the local store.

<a name="receiving-delegate-events"/>

## Delegate Events

ClubKit provides notifications on other events through delegate calls. Conform to `ClubMiddlewareDelegate` to receive these events.

Notifies receiver of errors

```swift
@objc optional func club(_ clubMiddleware: Club, didReceive error: Error)
```

Notifies receiver that a new MembershipUser object has been created.
Use this to show popup views, or update the UI, etc. if desired.
<b>NOTE</b> If displaying list of records in UITableView or UICollectionView, refer to this [section](#displaying-user-list) for updating the list

```swift
@objc optional func club(_ clubMiddleware: Club, didCreateNewMembership user: MembershipUser)
```

Notifies the delegate that a MembershipUser object has been updated.
Use this to show popup views, or update the UI, etc. if desired.
<b>NOTE</b> If displaying list of records in UITableView or UICollectionView, refer to this [section](#displaying-user-list) for updating the list

```swift
@objc optional func club(_ clubMiddleware: Club, didUpdateMembership user: MembershipUser)
```

Notifies the delegate that a MembershipUser object has been deleted.
Use this to show popup views, or update the UI, etc. if desired.
<b>NOTE</b> If displaying list of records in UITableView or UICollectionView, refer to this [section](#displaying-user-list) for updating the list

```swift
@objc optional func club(_ clubMiddleware: Club, didDeleteMembership user: MembershipUser)
```

<a name="import-users-delegate" />

Notifies the delegate that an array of `MembershipUser` objects have been imported from another device
Use this to store new list of transferred data in local Realm

```swift
@objc optional func club(_ clubMiddleware: Club, didReceiveImported users: [MembershipUser])
```
This function can be used to determine if the incoming list of user records should be merged with the existing local store
For example, an alert is displayed giving the developer, clerk, etc. the opportunity to accept or decline the imported user records.

```swift
func club(_ clubMiddleware: Club, didReceiveImported users: [MembershipUser]) {

    var alertStyle = UIAlertController.Style.actionSheet
    if (UIDevice.current.userInterfaceIdiom == .pad) {
        alertStyle = UIAlertController.Style.alert
    }
    
    let title = "Import"
    let message = "Received \(users.count) users to import. Would you like to save them?"
    
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: alertStyle)
                                            
    let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (_) in
        Club.shared.merge(importedUsers: users)
    }
    let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) { (_) in
        // Just decline and do nothing
    }
    
    alertController.addAction(yesAction)
    alertController.addAction(noAction)
    
    present(alertController, animated: true, completion: nil)
}
```

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
