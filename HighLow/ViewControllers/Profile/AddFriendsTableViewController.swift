//
//  AddFriendsTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 8/29/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class AddFriendsTableViewController: UITableViewController, UISearchBarDelegate {

    var users: [UserResource] = []
    let searchBar: UISearchBar = UISearchBar()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = getColor("White2Black")
        handleDarkMode()
        //Header
        tableView.tableHeaderView = UIView()
        
        //Navigation bar
        self.title = "Add Friends"
        //navigationController?.navigationBar.barTintColor = AppColors.primary
        //navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        
        //Left button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
        //navigationItem.leftBarButtonItem = cancelButton
        
        //Search bar
        searchBar.placeholder = "Search for new friends"
        searchBar.delegate = self
        
        tableView.tableHeaderView?.addSubview(searchBar)
        
        searchBar.eqTop(tableView.tableHeaderView!).centerX(tableView.tableHeaderView!).eqWidth(tableView.tableHeaderView!)
        
        tableView.tableHeaderView?.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        
        tableView.keyboardDismissMode = .onDrag

        searchUsers()
    }
    
    
    /*
    func getFriendSuggestions() {
        authenticatedRequest(url: "/user/friends/suggestions", method: .get, parameters: [:], onFinish: {
            json in
            if let users = json["users"] as? [NSDictionary] {
                self.users = []
                for i in users {
                    self.users.append( User(data: i) )
                }
                
                self.tableView.reloadData()
                
            }
            
        }, onError: { error in
            alert("An error occurred", "Please try again")
        })
    }*/
    
    
    
    
    func searchUsers() {
        
       searchBar.isLoading = true
        
        
        let params: [String: Any] = [
            "search": searchBar.text ?? ""
        ]
        UserService.shared.searchUsers(search: searchBar.text ?? "", onSuccess: { users in
            self.searchBar.isLoading = false
            self.users = users
            self.tableView.reloadData()
        }, onError: { error in
            alert()
            self.searchBar.isLoading = false
        })
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchBar.text?.count == 0 { return "Based on your interests" }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AddFriendTableViewCell(style: .default, reuseIdentifier: "user")
        cell.loadUser(users[indexPath.row].getItem())
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        openProfile(user: users[indexPath.row])
        
    }
    
    func openProfile(user: UserResource) {
        let profileTableViewController = NewProfileViewController()
        profileTableViewController.user = user
        
        self.navigationController?.pushViewController(profileTableViewController, animated: true)
    }
    
}

extension AddFriendsTableViewController {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchUsers()
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension UISearchBar {
    
    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }
    
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(style: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
