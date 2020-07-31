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
