//
//  DecodedDataView.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI
import ClubKit

struct DecodedDataView: View {
    
    let decodedDataWrapper: DecodedDataWrapper
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack (alignment: .leading) {
            
            Text(getGreeting(from: decodedDataWrapper.decodedData?.stringFromDecodedData()) ?? "")
                .font(Font.custom("Avenir Heavy", size: 25))
                .underline()
                .lineLimit(nil)
                .foregroundColor(Color.primary)
                .padding(.top, 20)
            Text(decodedDataWrapper.decodedData?.stringFromDecodedData() != nil ? "welcome to [BUSINESS NAME]" : "")
                .font(Font.custom("Avenir Heavy", size: 25))
                .underline()
                .lineLimit(nil)
                .foregroundColor(Color.primary)
                .padding(.top, 20)
            Text(getNumVisits(from: decodedDataWrapper.decodedData?.stringFromDecodedData()) ?? "")
                .font(.subheadline)
                .lineLimit(nil)
                .foregroundColor(Color.primary)
                .padding(.top, 20)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.leading)
        .padding(20)
        .background(Constants.SwiftUIConstants.getBackgroundColor(from: colorScheme))
    }
    
    
    
    private func getGreeting(from decodedDataString: String?) -> String? {
        guard let decodedDataString = decodedDataString else {
            return nil
        }
        
        let userInformation = UserInformation(decodedDataString: decodedDataString)
        
        let user = Club.shared.getUser(with: userInformation.userId)
        guard let username = user?.username else {
            return nil
        }
        return "Hello, \(username)"
    }
    
    private func getNumVisits(from decodedDataString: String?) -> String? {
        guard let decodedDataString = decodedDataString else {
            return nil
        }
        
        let userInformation = UserInformation(decodedDataString: decodedDataString)
        
        let user = Club.shared.getUser(with: userInformation.userId)
        guard let numberOfVisits = user?.numVisits else {
            return nil
        }
        if numberOfVisits == 1 {
            return "\(String(describing: user?.username ?? "[USERNAME]")) has visited for the first time!!!!"
        } else {
            return "\(String(describing: user?.username ?? "[USERNAME]")) has visited [BUSINESS NAME] \(numberOfVisits) times"
        }
        
    }
}
