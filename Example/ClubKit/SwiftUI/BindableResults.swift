//
//  BindableResults.swift
//  ClubKit_Example
//
//  Created by Chrishon Wyllie on 5/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import RealmSwift

class BindableResults<Element>: ObservableObject where Element: Object {

    @Published var results: Results<Element>
    private var resultsToken: NotificationToken?

    init(results: Results<Element>) {
        self.results = results
        setupInitialState(with: results)
    }


    deinit {
        resultsToken?.invalidate()
    }
    
    
    
    
    func setupInitialState(with results: Results<Element>) {
        resultsToken = results.observe { _ in
            self.results = results
        }
    }
    
    private func activateResultsToken() {
        let realm = try! Realm()
        let results = realm.objects(Element.self)
        resultsToken = results.observe { _ in
            self.results = results
        }
    }

    func deleteItems(at offsets: IndexSet) {
        print("deleteItems called.")
        let realm = try! Realm()

        do {
            try realm.write {
                offsets.forEach { index in
                    print("Attempting to access index \(index).")
                    if index < results.count {
                        print("Index is valid.")
                        let item = results[index]
//                        print("Removing \(item.name)")
                        realm.delete(item as Object)
                        print("Removed item.")
                    }
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
