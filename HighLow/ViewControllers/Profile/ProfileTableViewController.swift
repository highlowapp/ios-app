//
//  ProfileTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/18/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import TagListView

class ProfileTableViewController: UITableViewController, EditProfileViewControllerDelegate, HighLowTableViewCellDelegate, HighLowDelegate, ShowAllCommentsViewCellDelegate {
    
    let profileImage: HLImageView = HLImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    let bioLabel: UILabel = UILabel()
    let streakLabel: UILabel = UILabel()
    let buttons: UIView = UIView()
    let editButton: UIView = UIView()
    let tagList: TagListView = TagListView()
    
    var tags: [String] = []
    
    var firstName: String = ""
    var lastName: String = ""
    
    var uid: String?
    var email: String = ""
    
    var highlows: [HighLow] = []
    var sectionCommentsCollapseStates: [Bool] = []
    
    var page: Int = 0
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func highLowHasBeenUdpated(notification: Notification) {
        let userInfoDict = notification.userInfo as! [String: Any]
        
        if let hli = userInfoDict["highlowid"] as? String {
            
            for i in highlows.indices {
                if hli == highlows[i].highlowid {
                    highlows[i].update(with: notification.userInfo as! [String: Any])
                }
            }
            
        }
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NotificationCenter.default.addObserver(forName: Notification.Name("highLowUpdate"), object: nil, queue: nil, using: highLowHasBeenUdpated)
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(ShowAllCommentsViewCell.self, forCellReuseIdentifier: "ShowComments")
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(getProfile), for: .valueChanged)
        
        self.title = "Profile"
        
        tableView.tableHeaderView = UIView()
        
        navigationController?.navigationBar.barStyle = .black
        
        navigationController?.navigationBar.barTintColor = AppColors.primary
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        //Separator
        let separator = UIView()
        separator.backgroundColor = rgb(240, 240, 240)
        
        tableView.tableHeaderView?.addSubview(separator)
    separator.eqTop(tableView.tableHeaderView!).eqLeading(tableView.tableHeaderView!).eqTrailing(tableView.tableHeaderView!).height(1)
        
        //Header
        let header = GradientUIView()
        header.angle = -45
        header.startColor = AppColors.primary
        header.endColor = AppColors.secondary
        
        tableView.tableHeaderView?.addSubview(header)
        
        header.topToBottom(separator).eqLeading(tableView.tableHeaderView!).eqTrailing(tableView.tableHeaderView!)
        
        //ProfileImage
        profileImage.layer.cornerRadius = 150 / 2
        profileImage.showBorder(.white, 3)
        
        header.addSubview(profileImage)
        
        profileImage.centerX(header).width(150).height(150).eqTop(header, 60)
        
        //nameLabel
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 25)
        nameLabel.textAlignment = .center
        nameLabel.text = ""
        
        header.addSubview(nameLabel)
        
        nameLabel.topToBottom(profileImage, 20).centerX(tableView.tableHeaderView!)
    
        //bioLabel
        bioLabel.textColor = .white
        bioLabel.font = .systemFont(ofSize: 15)
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        bioLabel.text = ""
        
        //friendsImageView
        let friends = UIView()
        friends.layer.cornerRadius = 5
        friends.showBorder(.white, 1)
        
        let friendsIcon = UIImageView(image: UIImage(named: "friends"))
        friendsIcon.contentMode = .scaleAspectFill
        friendsIcon.clipsToBounds = true
        
        let friendsLabel = UILabel()
        friendsLabel.text = "Friends"
        friendsLabel.textColor = .white
        
        friends.addSubview(friendsIcon)
        friends.addSubview(friendsLabel)
        
        friendsIcon.eqTop(friends, 5).eqLeading(friends, 10)
        friendsLabel.centerY(friendsIcon).leadingToTrailing(friendsIcon, 5)
        
        
        buttons.addSubview(friends)
        buttons.addSubview(editButton)
        
        editButton.showBorder(.white, 1)
        editButton.layer.cornerRadius = 5
        
        friends.eqBottom(friendsIcon, 5).eqTrailing(friendsLabel, 10).eqLeading(buttons).eqTop(buttons)
        buttons.eqBottom(friends).eqTrailing(editButton)
        editButton.leadingToTrailing(friends, 10).eqTop(buttons).eqBottom(friends)
        
        friends.isUserInteractionEnabled = true
        
        let friendsTapper = UITapGestureRecognizer(target: self, action: #selector(showFriends))
        friends.addGestureRecognizer(friendsTapper)
        
        
        //streakView
        streakLabel.textColor = .white
        streakLabel.font = .systemFont(ofSize: 25)
        streakLabel.text = "0"
        
        header.addSubview(streakLabel)
        
        streakLabel.leadingToTrailing(profileImage, 20).centerY(profileImage)
        
        //streakIcon
        let streakIcon = UIImageView(image: UIImage(named: "streak"))
        streakIcon.contentMode = .scaleAspectFill
        
        header.addSubview(streakIcon)
        
        streakIcon.leadingToTrailing(streakLabel).centerY(streakLabel).width(40).height(40)
        
        header.addSubview(bioLabel)
        
        bioLabel.topToBottom(nameLabel, 10).centerX(tableView.tableHeaderView!).width(200)
            
        tagList.textColor = .black
        tagList.tagBackgroundColor = .white
        tagList.cornerRadius = 17
        tagList.textFont = .systemFont(ofSize: 15)
        tagList.paddingX = 10
        tagList.paddingY = 10
        tagList.alignment = .center
        
        header.addSubview(tagList)
        
        tagList.topToBottom(bioLabel, 10).centerX(self.view).eqWidth(self.view, 0.0, 0.8)
        
        let container = UIView()
        
        header.addSubview(container)
        
        container.addSubview(buttons)
        
        container.topToBottom(tagList, 10).eqWidth(view).eqBottom(buttons)
        buttons.centerX(container).eqTop(container)
        header.eqBottom(friends, 20)        
        
        //tableHeaderView constraints
        tableView.tableHeaderView?.clipsToBounds = true
        tableView.tableHeaderView?.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        
        
        getProfile()
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return highlows.count > 0 ? highlows.count:1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if highlows.count == 0 {
            return 1
        }
        return (sectionCommentsCollapseStates[section]) ? ( min(1, highlows[section].comments.count) + 3 ) : ( highlows[section].comments.count + 3 )
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if highlows.count == 0 {
            let cell = MessageTableViewCell(style: .default, reuseIdentifier: "message")
            return cell
        }
        
        let highLow = self.highlows[indexPath.section]
        
        if indexPath.row == 0 {
        
            //Use a HighLowView
            let cell = HighLowTableViewCell(style: .default, reuseIdentifier: "highlow")/*tableView.dequeueReusableCell(withIdentifier: "highlow") as! HighLowTableViewCell*/
            
            cell.delegate = self
            
            cell.loadData(profileImage: profileImage.url, name: self.nameLabel.text, highlow: highlows[indexPath.section])
            
            return cell
            
        }
            
        else if indexPath.row == 1 {
            let cell = LikeFlagTableViewCell(style: .default, reuseIdentifier: "likeFlag")
            cell.highlowid = highlows[indexPath.section].highlowid
            cell.loadFromHighLow(highlow: highlows[indexPath.section])
            return cell
        }
            
        else if sectionCommentsCollapseStates[ indexPath.section ] && indexPath.row == min(1, highlows[indexPath.section].comments.count) + 2 {
            
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.delegate = self
            cell.active = false
            cell.section = String(indexPath.section)//highlows[indexPath.section].date
            cell.state = !sectionCommentsCollapseStates[indexPath.section]
            return cell
            
        } else if !sectionCommentsCollapseStates[ indexPath.section ] && indexPath.row == highlows[indexPath.section].comments.count + 2 {
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.section = highlows[indexPath.section].date
            cell.active = false
            cell.delegate = self
            cell.state = !sectionCommentsCollapseStates[indexPath.section]
            return cell
        }
        
        else {
            
            //Use a comment cell
            let cell = CommentViewCell(comment: highLow.comments[ indexPath.row - 2 ] )
            cell.indentationLevel = 1
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section >= page * 10 {
            page += 1
            self.loadHighLows(page: page)
        }
    }
    
    
    
    func didFinishLoadingComments(sender: HighLow) {
        tableView.reloadData()
    }
    
    @objc func showFriends() {
        
        
        let friendsTableViewController = FriendsTableViewController()
        
        if uid != nil {
            friendsTableViewController.uid = uid!
        }
        
        //Navigation bar
        let navigationBar = UINavigationController(rootViewController: friendsTableViewController)
        navigationBar.navigationBar.tintColor = AppColors.primary
        navigationBar.navigationBar.barStyle = .black
        
        self.present(navigationBar, animated: true)
    }
    
    
    
    @objc func getProfile() {
        
        var url = "https://api.gethighlow.com/user/get"
        if self.uid != nil {
            url += "?uid=" + self.uid!
        }
        authenticatedRequest(url: url, method: .post, parameters: [:], onFinish: { json in
            if let uid = json["uid"] as? String {
                self.uid = uid
                
                let profileImageURL = json["profileimage"] as! String
                let firstName = json["firstname"] as! String
                let lastName = json["lastname"] as! String
                let email = json["email"] as! String
                self.email = email
                self.firstName = firstName
                self.lastName = lastName
                let bio = json["bio"] as! String
                let streak = json["streak"] as! Int
                let interests = json["interests"] as! [String]
                
                var imageURL = ""
                if profileImageURL.starts(with: "http") {
                    imageURL = profileImageURL
                } else {
                    imageURL = "https://storage.googleapis.com/highlowfiles/" + profileImageURL
                }
                    
                
                self.profileImage.loadImageFromURL(imageURL)
                self.nameLabel.text = firstName + " " + lastName
                self.bioLabel.text = bio
                self.streakLabel.text = String(streak)
                self.tags = interests
                self.tagList.removeAllTags()
                self.tagList.addTags(interests)
                
                
                getUid() { uid in
                    if uid == self.uid {
                        let tapToEditLabel = UILabel()
                        tapToEditLabel.text = "Edit Profile"
                        //tapToEditLabel.font = .systemFont(ofSize: 15)
                        tapToEditLabel.textColor = .white
                        
                        //self.tableView.tableHeaderView!.addSubview(tapToEditLabel)
                        self.editButton.addSubview(tapToEditLabel)
                        
                        tapToEditLabel.translatesAutoresizingMaskIntoConstraints = false
                        /*
                        tapToEditLabel.bottomAnchor.constraint(equalTo: self.profileImage.topAnchor, constant: -30).isActive = true
                        tapToEditLabel.centerXAnchor.constraint(equalTo: self.profileImage.centerXAnchor).isActive = true
                        */
                        tapToEditLabel.topAnchor.constraint(equalTo: self.editButton.topAnchor, constant: 5).isActive = true
                        tapToEditLabel.leadingAnchor.constraint(equalTo: self.editButton.leadingAnchor, constant: 10).isActive = true
                        self.editButton.trailingAnchor.constraint(equalTo: tapToEditLabel.trailingAnchor, constant: 10).isActive = true
                        self.editButton.bottomAnchor.constraint(equalTo: tapToEditLabel.bottomAnchor,  constant: 5).isActive = true
                        
                        
                        //Add UIGestureRecognizer
                        let tapper = UITapGestureRecognizer(target: self, action: #selector(self.editProfile))
                        self.editButton.addGestureRecognizer(tapper)
                    }
                }
                
                self.loadHighLows(page: 0, reset: true)
            } else {
                
                alert("An error occurred", "Try closing the app and opening it again")
                
            }
            
        }, onError: { error in
            
            alert("An error occurred", "Try closing the app and opening it again")
            
        })
        
        
    }
    
    
    func loadHighLows(page: Int = 0, reset: Bool = false) {
        
        
        var url = "https://api.gethighlow.com/highlow/get/user/page/" + String(page)
        if self.uid != nil {
            url += "?uid=" + self.uid!
        }
        authenticatedRequest(url: url, method: .get, parameters: [:], onFinish: { json in
            if let highlows = json["highlows"] as? [NSDictionary] {
                if reset {
                    self.page = 0
                    self.highlows = []
                    self.sectionCommentsCollapseStates = []
                }
                
                for i in highlows {
                    let highLow = HighLow(data: i)
                    highLow.delegate = self
                    self.highlows.append( highLow )
                    self.sectionCommentsCollapseStates.append(true)
                }
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
            
        }, onError: { error in
            
            alert("An error occurred", "Try refreshing the page.")
            
        })
        
    }
    

    @objc func editProfile() {
        
        let editProfileViewController = EditProfileViewController()
        editProfileViewController.formState = [
            "firstName": self.firstName,
            "lastName": self.lastName,
            "email": self.email,
            "bio": self.bioLabel.text ?? "",
            "profileImage": self.profileImage.url ?? "",
            "tags": tags
        ]
        editProfileViewController.delegate = self
        self.present(editProfileViewController, animated: true)
        
    }
}




extension ProfileTableViewController {
    func editProfileViewControllerDidEndEditing() {
        getProfile()
    }
    
    func openHomeViewController(homeViewController: HomeViewController) {
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
}


extension ProfileTableViewController {
    func showAll(sender: ShowAllCommentsViewCell) {
        /*if sender.section != nil {
            sectionCommentsCollapseStates[sender.section!] = false
        }
        
        tableView.reloadData()*/
        
        let homeViewController = UIStoryboard(name: "Tabs", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.highlow = highlows[Int(sender.section!)!]
        homeViewController.commentsAreCollapsed = false
        openHomeViewController(homeViewController: homeViewController)
    }
    
    func collapse(sender: ShowAllCommentsViewCell) {
        /*if sender.section != nil {
            sectionCommentsCollapseStates[sender.section!] = true
        }
        
        tableView.reloadData()*/
    }
}
