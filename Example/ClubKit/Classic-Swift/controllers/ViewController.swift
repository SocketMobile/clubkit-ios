//
//  ViewController.swift
//  ClubKit
//
//  Created by Chrishon on 05/18/2020.
//  Copyright (c) 2020 Chrishon. All rights reserved.
//

import UIKit
import ClubKit
import RealmSwift

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private let cellReuseIdentifier = "cellReuseIdentifier"
    
    private var users: Results<MembershipUser>!
    private var usersToken: NotificationToken?
    
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tbv = UITableView(frame: .zero)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.backgroundColor = UIColor.systemGroupedBackground
        tbv.delegate = self
        tbv.dataSource = self
        tbv.alwaysBounceVertical = true
        tbv.separatorStyle = .none
        return tbv
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUIElements()
        loadAllRecords()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        // Allow edit actions on the tableview, such as deleting users
        tableView.setEditing(editing, animated: true)
    }
    
    private func setupUIElements() {
        
        self.title = "Stored Users"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = self.editButtonItem
        view.backgroundColor = .white
        
        
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
    }
    
    private func loadAllRecords() {
        do {
            let realm = try Realm()
            users = realm.objects(MembershipUser.self)
            
            usersToken = users.observe({ [weak self] (changes) in
                guard let strongSelf = self else { return }
                strongSelf.updateUI(with: changes)
            })
        } catch let error {
            print("Error getting realm reference: \(error)")
        }
    }
    
    private func updateUI(with changes: RealmCollectionChange<Results<MembershipUser>>) {
        switch changes {
        case .initial(_):
            tableView.reloadData()
        case let .update(_, deletions, insertions, modifications):
            tableView.performBatchUpdates({
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            }, completion: { (completed: Bool) in
                self.tableView.reloadData()
            })
            break
        case let .error(error):
            print(error.localizedDescription)
        }
    }

}






// MARK: - UITableViewDelegate and UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? UserCell
        
        let user = users[indexPath.item]
        cell?.setup(with: user)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
    
            let user = users[indexPath.item]
            
            showAlertForDeleting(user: user)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    private func showAlertForDeleting(user: MembershipUser) {
        
        let title = "Are you sure you want to delete this user?"
        let message = "This is a permanent action and cannot be reversed"
        let style = UIAlertControllerStyle.alert
        
        
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: style)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (_) in
            if let error = Club.shared.deleteUser(user) {
                print("error deleting user: \(String(describing: user.username)). Error: \(error.localizedDescription)")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.navigationController?.present(alertController, animated: true, completion: nil)
        
    }
}
