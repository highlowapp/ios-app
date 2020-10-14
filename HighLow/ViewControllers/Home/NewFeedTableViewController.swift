//
//  NewFeedTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class NewFeedTableViewController: UITableViewController {
    
    var feed: [NSDictionary] = []
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureNavBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = rgb(240, 240, 240)
        
        UserService.shared.getFeed(page: 0, onSuccess: { feedArr in
            self.feed = []
            for item in feedArr {
                self.feed.append(item)
            }
            self.tableView.reloadData()
            
        }, onError: { error in
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feed.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = feed[indexPath.row]
        switch item["type"] as! String {
        case "activity_chart":
            let cell = ActivityChartCell()
            cell.awakeFromNib()
            cell.setChartData(item["chart"] as! [NSDictionary])
            return cell
        case "announcement":
            let cell = AnnouncementTableViewCell()
            cell.awakeFromNib()
            cell.messageLabel.text = item["message"] as? String
            
            var color = AppColors.secondary
            switch item["severity"] as! Int {
            case 2:
                color = .red
            break
            default:
                break
            }
            
            cell.contView.backgroundColor = color
            
            cell.url = item["link"] as! String
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    

    
}

extension UIViewController {
    func configureNavBar() {
        if #available(iOS 13.0, *) {
            let navBarApp = UINavigationBarAppearance()
            navBarApp.configureWithOpaqueBackground()
            navBarApp.backgroundColor = .white
            navBarApp.shadowColor = .clear
            
            navigationController?.navigationBar.standardAppearance = navBarApp
            navigationController?.navigationBar.scrollEdgeAppearance = navBarApp
            navigationController?.navigationBar.compactAppearance = navBarApp
        } else {
            navigationController?.navigationBar.barTintColor = .white
        }
        
        navigationController?.navigationBar.tintColor = AppColors.primary
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 7.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.15
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
}
