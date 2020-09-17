//
//  CustomMembershipUser.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 6/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ClubKit

@objcMembers class CustomMembershipUser: MembershipUser {
    
    dynamic var emailAddress: String? = "Some Email address"
    dynamic var greeting: String?
    dynamic var age: Int = 0
    dynamic var field1: Int = 1
    dynamic var field2: Int = 2
    dynamic var countryCode: String = ""
//    dynamic var field4: Int = 4
//    dynamic var field5: Int = 5
    
    override class func variableNamesAsStrings() -> [String] {
        let superclassNames = super.variableNamesAsStrings()
        return superclassNames + CodingKeys.allCases.map { $0.rawValue }
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case emailAddress
        case greeting
        case age
        case field1
        case field2
        case countryCode // created as field3 (before field4) then renamed to countryCode (after deleting field4)
        case field4 // created (before field5) then deleted (after deleting field5)
        case field5 // created then deleted
    }
    
    required init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws  {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emailAddress = try container.decode(String.self, forKey: .emailAddress)
        greeting = try container.decode(String.self, forKey: .greeting)
        age = try container.decode(Int.self, forKey: .age)
        field1 = try container.decode(Int.self, forKey: .field1)
        field2 = try container.decode(Int.self, forKey: .field2)
        countryCode = try container.decode(String.self, forKey: .countryCode)
//        field4 = try container.decode(Int.self, forKey: .field4)
//        field5 = try container.decode(Int.self, forKey: .field5)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(greeting, forKey: .greeting)
        try container.encode(age, forKey: .age)
        try container.encode(field1, forKey: .field1)
        try container.encode(field2, forKey: .field2)
        try container.encode(countryCode, forKey: .countryCode)
//        try container.encode(field4, forKey: .field4)
//        try container.encode(field5, forKey: .field5)
    }
}
