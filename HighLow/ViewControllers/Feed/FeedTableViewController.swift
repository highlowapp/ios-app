//
//  FeedTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/3/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, ShowAllCommentsViewCellDelegate, HighLowTableViewCellDelegate, HomeViewControllerDelegate {
    
    var highlows: [HighLow] = []
    var users: [User] = []
    var sectionCommentsCollapseStates: [Bool] = []
    var page: Int = 0
    
    var activeHighLow: Int = 0
    
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
        
        NotificationCenter.default.addObserver(forName: Notification.Name("highLowUpdate"), object: nil, queue: nil, using: highLowHasBeenUdpated)
        
        super.viewDidLoad()
        
        tableView.register(ShowAllCommentsViewCell.self, forCellReuseIdentifier: "ShowComments")
        //tableView.register(LikeFlagTableViewCell.self, forCellReuseIdentifier: "LikeFlag")
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadFeedItems), for: .valueChanged)
        
        self.loadFeedItems(reset: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return highlows.count > 0 ? highlows.count : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if highlows.count == 0 {
            return 1
        }
        return  min(1, highlows[section].comments.count) + 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if highlows.count == 0 {
            let cell = MessageTableViewCell(style: .default, reuseIdentifier: "message")
            cell.setMessage("Looks like there's nothing in your feed yet. As you make friends on the app, their High/Lows will show up here for you to see.")
            return cell
        }
        
        let highLow = self.highlows[indexPath.section]
        
        if indexPath.row == 0 {
            
            //Use a HighLowView
            let cell = tableView.dequeueReusableCell(withIdentifier: "highlow") as! HighLowTableViewCell
            
            cell.delegate = self
            
            cell.loadData(profileImage: users[indexPath.section].profileimage, name: users[indexPath.section].firstname! + " " + users[indexPath.section].lastname!, highlow: highlows[indexPath.section])
            
            return cell
            
        }
            
        else if indexPath.row == 1 {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "LikeFlag", for: indexPath) as! LikeFlagTableViewCell
            let cell = LikeFlagTableViewCell(style: .default, reuseIdentifier: "_LikeFlag")
            cell.highlowid = highlows[indexPath.section].highlowid
            cell.loadFromHighLow(highlow: highlows[indexPath.section])
            return cell
        }
            
        else if indexPath.row == min(1, highlows[indexPath.section].comments.count) + 2 {
            
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.delegate = self
            cell.active = false
            cell.section = String(indexPath.section)
            cell.state = !sectionCommentsCollapseStates[indexPath.section]
            return cell
            
        } else if !sectionCommentsCollapseStates[ indexPath.section ] && indexPath.row == highlows[indexPath.section].comments.count + 2 {
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.section = String(indexPath.section)
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

    @objc func loadFeedItems(page: Int = 0, reset: Bool = false) {
        let loader = HLLoaderView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(loader)
        
        loader.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        loader.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        loader.startLoading()
        
        authenticatedRequest(url: "https://api.gethighlow.com/user/feed/page/" + String(page), method: .get, parameters: [:], onFinish: { json in
            loader.stopLoading()
            loader.removeFromSuperview()
            self.tableView.refreshControl?.endRefreshing()
            if let feed = json["feed"] as? [NSDictionary] {
                if reset {
                    self.highlows = []
                    self.users = []
                    
                    self.page = 0
                }
                
                for item in feed {
                    let user = item["user"] as! NSDictionary
                    let highlow = item["highlow"] as! NSDictionary
                    
                    self.highlows.append( HighLow(data: highlow) )
                    self.users.append( User(data: user) )
                    self.sectionCommentsCollapseStates.append(true)
                }
                
                self.tableView.reloadData()
            }
            
        }, onError: { error in
            loader.stopLoading()
            loader.removeFromSuperview()
            self.tableView.refreshControl?.endRefreshing()
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //10 is the maximum number of High/Lows per "page"
        if indexPath.section >= page * 10 {
            page += 1
            self.loadFeedItems(page: page)
            
        }
    }
}


extension FeedTableViewController {
    func openHomeViewController(homeViewController: HomeViewController) {
        homeViewController.delegate = self
        self.navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    func showAll(sender: ShowAllCommentsViewCell) {
        let homeViewController = UIStoryboard(name: "Tabs", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.activeHighLow = Int(sender.section!)!
        homeViewController.highlow = highlows[self.activeHighLow]
        homeViewController.commentsAreCollapsed = false
        openHomeViewController(homeViewController: homeViewController)
    }
    
    func collapse(sender: ShowAllCommentsViewCell) {
    }
    
    func hasBeenRemovedFromParent(sender: HomeViewController) {
        //loadFeedItems()
    }
}
