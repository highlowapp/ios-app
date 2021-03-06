//
//  FriendsTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 8/24/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, FriendTableViewCellDelegate, PendingFriendRequestTableViewCellDelegate {
    
    var friends: [UserResource] = []
    var uid: String?
    var pendingRequests: [User] = []
    var isCurrentUser: Bool = false
    
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
    
    override func updateViewColors() {
        self.view.backgroundColor = getColor("White2Black")
        tableView.visibleCells.forEach({ cell in
            cell.updateColors()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        updateViewColors()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        //Navigation bar
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.navigationBar.barTintColor = AppColors.primary
        self.title = "Friends"
        
        //Edit button
        let editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editMode))
        editButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.primary], for: .normal)
        self.navigationItem.rightBarButtonItem = editButton
        
        //Back button
        let backButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
        backButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.primary], for: .normal)
        //self.navigationItem.leftBarButtonItem = backButton
        
        
        reloadData()
        
        
    }
    
    
    func addFriendsButton() {
        //Header
        tableView.tableHeaderView = UIView()
        
        let addFriends = UIButton()
        addFriends.backgroundColor = AppColors.primary
        addFriends.layer.cornerRadius = 5
        addFriends.setTitleColor(.white, for: .normal)
        addFriends.setTitle("Add Friends", for: .normal)
        addFriends.setImage(UIImage(named: "add_friend"), for: .normal)
        
        addFriends.addTarget(self, action: #selector(openAddFriendsViewController), for: .touchUpInside)
        
        tableView.tableHeaderView?.backgroundColor = .white
        tableView.tableHeaderView?.addSubview(addFriends)
        
        addFriends.centerX(tableView.tableHeaderView!).eqTop(tableView.tableHeaderView!, 10).width(150).height(50)
        
        tableView.tableHeaderView!.bottomAnchor.constraint(equalTo: addFriends.bottomAnchor, constant: 10).isActive = true
    }
    
    
    func getPendingRequests() {

        authenticatedRequest(url: "/user/get_pending_friendships", method: .get, parameters: [:], onFinish: { json in
            if let requests = json["requests"] as? [NSDictionary] {
                self.pendingRequests = []
                for i in requests {
                    self.pendingRequests.append( User(data: i) )
                }
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
            
        }, onError: { error in
            
        })
        
    }
    
    func getFriends(callback: @escaping () -> Void) {
        guard let uid = self.uid else { return }
        UserService.shared.getFriendsForUser(uid: uid, onSuccess: { friendsResponse in
            self.friends = friendsResponse.friends
            callback()
            self.tableView.reloadData()
        }, onError: { error in
            alert()
            callback()
        })
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isCurrentUser && pendingRequests.count > 0 {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && pendingRequests.count > 0  {
            return pendingRequests.count
        }
        
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && pendingRequests.count > 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && pendingRequests.count > 0 {
            
            let cell = PendingFriendRequestTableViewCell(style: .default, reuseIdentifier: "friend")
            cell.loadUser( pendingRequests[indexPath.row] )
            cell.delegate = self
            return cell
            
        } else {
            let cell = FriendTableViewCell(style: .default, reuseIdentifier: "friend")
            cell.loadUser( friends[indexPath.row].getItem() )
            cell.delegate = self
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && pendingRequests.count > 0 {
            return "Pending Friend Requests"
        }
        return "Your Friends"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let uid = friends[indexPath.row].uid!
        
        authenticatedRequest(url: "/user/" + uid + "/unfriend", method: .post, parameters: [:], onFinish: { json in
            if json["status"] != nil {
                self.friends.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .bottom)
            }
        }, onError: { error in
            
            
            
        })
        
    }
    
    @objc func editMode() {
        
        if tableView.isEditing == true {
            
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.title = "Edit"
            
        } else {
            
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.title = "Done"
            
        }
        
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && pendingRequests.count > 0 {
            openProfile( uid: pendingRequests[indexPath.row].uid! )
        } else {
            let profileViewController = NewProfileViewController()
            profileViewController.user = self.friends[indexPath.row]
            self.navigationController?.navigationBar.tintColor = AppColors.primary
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        
    }
    
    
    func openProfile(uid: String) {
        let profileTableViewController = UIStoryboard(name: "Tabs", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        
        profileTableViewController.uid = uid
        
        self.navigationController?.pushViewController(profileTableViewController, animated: true)
    }
    
    @objc func reloadData() {
        
        getFriends() {
            getUid(callback: { uid in
                if self.uid == uid {
                    self.isCurrentUser = true
                    self.addFriendsButton()
                }
            })
        }
        
    }
    
    func requestAccepted() {
        reloadData()
    }
    
    func requestRejected() {
        reloadData()
    }
    
    @objc func openAddFriendsViewController() {

        let addFriendsTableViewController = AddFriendsTableViewController()
        
        self.navigationController?.pushViewController(addFriendsTableViewController, animated: true)
    }

}
