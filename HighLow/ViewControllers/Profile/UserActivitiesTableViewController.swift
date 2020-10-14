//
//  UserActivitiesTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit

class UserActivitiesTableViewController: UITableViewController {
    
    var user: UserResource? {
        didSet {
            self.loadActivities()
        }
    }
    
    var activities: [ActivityResource] = []
    
    var rowHeights: [Int: CGFloat] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = rgb(240, 240, 240)
        tableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: "diary")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.contentInset.bottom = 100
        
        loadActivities()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activity = activities[indexPath.row]
        switch activity.type! {
        case "diary", "highlow":
            let diaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "diary", for: indexPath) as! DiaryTableViewCell
            let height = rowHeights[indexPath.row] ?? 0
            diaryTableViewCell.setHeight(height)
            diaryTableViewCell.setUser(user)
            diaryTableViewCell.setActivity(activity)
            diaryTableViewCell.delegate = self
            diaryTableViewCell.indexPath = indexPath
            diaryTableViewCell.activityView.load()
            return diaryTableViewCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func loadActivities(page: Int = 0) {
        user?.getActivities(page: page, onSuccess: { activities in
            
            let numPages = self.activities.count/10
            if numPages > page + 1 {
                self.activities.removeSubrange((page * 10)..<numPages * 10)
            }
            self.activities.append(contentsOf: activities)
            self.tableView.reloadData()
        }, onError: { error in
            
        })
    }
}

extension UserActivitiesTableViewController: DiaryTableViewCellDelegate {
    func diaryTableViewCell(_ cell: DiaryTableViewCell, didUpdateHeight height: CGFloat, atRow row: Int) {
        rowHeights[row] = height
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func diaryTableViewCell(_ cell: DiaryTableViewCell, didFinishLoadingWebViewAtIndexPath indexPath: IndexPath) {
        
    }
}
