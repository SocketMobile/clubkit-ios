//
//  CoreDataListView.swift
//  MembershipDemo
//
//  Created by Chrishon Wyllie on 5/6/20.
//  Copyright © 2020 Chrishon Wyllie. All rights reserved.
//

import SwiftUI
import ClubKit
import RealmSwift

struct CoreDataListView: View {
    
//    @FetchRequest(
//        entity: MembershipUser.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \MembershipUser.username, ascending: true),
//            NSSortDescriptor(keyPath: \MembershipUser.timeStampOfLastVisit, ascending: false)
//        ]
//    ) var users: FetchedResults<MembershipUser>
    
//    @State private var refreshing = false
//    private var didSave = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
//    private var didChange = NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
    
    @State private var users = BindableResults(results: try! Realm().objects(MembershipUser.self))
//    private var users: Results<RealmMembershipUser>!
//    private var usersToken: NotificationToken?
//    @ObservedObject var users = BindableResults(results: try! Realm().objects(RealmMembershipUser.self))
//    @ObservedObject var users = BindableResults(results: <#T##Results<Object>#>)
    
    init() {
//        loadAllRecords()
        
//        let realm = try! Realm()
//        users = realm.objects(RealmMembershipUser.self)
        
        removeListSeparators()
    }
    
//    private mutating func loadAllRecords() {
//        do {
//            let realm = try Realm()
//            users = realm.objects(RealmMembershipUser.self)
////            usersToken = users.observe({ (changes) in
////                <#code#>
////            })
//        } catch let error {
//            print("Error getting realm reference: \(error)")
//        }
//    }
    
    var body: some View {
        VStack {
            List {
                ForEach(users.results, id: \.userId) { user in
                    LocalStorageCell(user: user)
                }
                .onDelete(perform: removeItem)
            }
        }
        .navigationBarTitle(Text("Stored Users"))
        .navigationBarItems(trailing: EditButton().foregroundColor(Constants.SwiftUIConstants.AppTheme.primaryColor))
    }
    
    private func removeItem(at offsets: IndexSet) {
        for index in offsets {
            let user = users.results[index]
            Club.shared.deleteUser(user)
        }
    
        let realm = try! Realm()
        users = BindableResults(results: try! Realm().objects(MembershipUser.self))
//        users = realm.objects(RealmMembershipUser.self)
//        users.deleteItems(at: offsets)
        
    }
    
    private func removeListSeparators() {
        // To remove only extra separators below the list:
        UITableView.appearance().tableFooterView = UIView()

        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
}

struct LocalStorageCell: View {
    
    let user: MembershipUser
    let userInfoItems: [InfoKeyValuePair]
    
    init(user: MembershipUser) {
        self.user = user
        
        userInfoItems = [
            .init(title: "User name:", value: user.username ?? "Unknown Name"),
            .init(title: "User Unique ID:", value: user.userId ?? "Unknown ID"),
            .init(title: "Date Addded:", value: "\(Date(timeIntervalSince1970: user.timeStampAdded))"),
            .init(title: "Date of last visit:", value: "\(Date(timeIntervalSince1970: user.timeStampOfLastVisit))"),
            .init(title: "Number of visits:", value: "\(Int(user.numVisits))")
        ]
    }
    
    
    
    var body: some View {
        VStack (alignment: .leading) {
            CardView(items: userInfoItems)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .leading)
        }
        .background(Constants.SwiftUIConstants.AppTheme.primaryColor)
        .cornerRadius(Constants.SwiftUIConstants.UIFormat.roundedCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.SwiftUIConstants.UIFormat.roundedCornerRadius)
                .stroke(Constants.SwiftUIConstants.AppTheme.primaryColor, lineWidth: Constants.SwiftUIConstants.UIFormat.roundedBorderWidth)
        )
        .shadow(radius: Constants.SwiftUIConstants.UIFormat.shadowRadius)
        .padding(.init(top: 30, leading: 0, bottom: 30, trailing: 0))
    }
}

struct CoreDataView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataListView()
    }
}











struct CardView: View {
    let items: [InfoKeyValuePair]
    
    var body: some View {
        VStack (alignment: .leading) {
           List {
                ForEach(self.items, id: \.id) { item in
                    InfoView(info: item)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
        }
    }
}

struct InfoKeyValuePair: Identifiable {
    var id: String {
        return UUID().uuidString
    }
    let title: String
    let value: String
}

struct InfoView: View {
    
    let info: InfoKeyValuePair
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(info.title)
                .font(.headline)
                .foregroundColor(Color.primary)
                .underline()
                .lineLimit(nil)
                
            Text(info.value)
                .font(.subheadline)
                .lineLimit(nil)
                .foregroundColor(Color.primary)
        }
    }
}


