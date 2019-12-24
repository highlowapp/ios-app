//
//  NotificationsSettingsViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/12/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class NotificationsSettingsViewController: UITableViewController, DailyNotificationSwitchCellDelegate {
    
    func dailyNotification(didSwitchToState state: Bool) {
        if state {
            datePickerExists = true
            tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
        } else {
            datePickerExists = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UserDefaults.standard.removeObject(forKey: "com.gethighlow.DailyNotifTime")
            tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
        }
        
    }
    
    
    var options: [[Any]] = [
        ["New Friend Requests", "notify_new_friend_req", true],
        ["Friend Request Accepted", "notify_new_friend_acc", true],
        ["New Feed Items", "notify_new_feed_item", true],
        ["Likes", "notify_new_like", true],
        ["Comments", "notify_new_comment", true]
    ]
    
    var datePickerExists = false
    var timePickerDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notification Settings"
        
        tableView.register(DailyNotificationSwitchCell.self, forCellReuseIdentifier: "dailyNotifier")
        
        if let dailyNotifTime = UserDefaults.standard.object(forKey: "com.gethighlow.DailyNotifTime") as? Date {
            datePickerExists = true
            timePickerDate = dailyNotifTime
        }
       
        //We need a few things:
        //    - A switch and time selector
        //    - A list of switches for various notifications
        getNotifSettings()
        
    }
    
    func getNotifSettings() {
        authenticatedRequest(url: "https://api.gethighlow.com/notifications/settings", method: .get, parameters: [:], onFinish: { json in
            if json["error"] != nil {
                alert("An error occurred", "Please try again")
                return
            }
            else {
                for i in self.options.indices {
                    self.options[i][2] = (json[self.options[i][1]] as! Int == 1)
                }
                self.tableView.reloadData()
            }
        }, onError: { error in
            alert("An error occurred", "Please try again")
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return options.count
        }
        
        return datePickerExists ? 2:1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = NotificationOptionCell(style: .default, reuseIdentifier: "notificationOption")
            
            let cellInfo = options[indexPath.row]
            let label = cellInfo[0],
                setting = cellInfo[1],
                state = cellInfo[2]
            
            cell.initialize(label: label as! String, setting: setting as! String, state: state as! Bool)
            
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dailyNotifier", for: indexPath) as! DailyNotificationSwitchCell
            cell.delegate = self
            cell.setSwitch(toState: datePickerExists)
            return cell
        }
        
        let cell = TimePickerCell(style: .default, reuseIdentifier: "timePicker")
        cell.timePicker.date = timePickerDate
        return cell
    }
    
    

}


class NotificationOptionCell: UITableViewCell {
    
    var label: String = "" {
        didSet {
            self.textLabel?.text = label
        }
    }
    var setting: String = ""
    var state: Bool = false
    
    let switchView: UISwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public func initialize(label: String, setting: String, state: Bool) {
        self.label = label
        self.setting = setting
        self.state = state
        self.setState(value: state)
    }
    
    private func setup() {
        self.switchView.onTintColor = AppColors.primary
        self.switchView.addTarget(self, action: #selector(toggle), for: .valueChanged)
        self.setState(value: self.state)
        self.accessoryView = self.switchView
    }
    
    func setState(value: Bool) {
        if value {
            self.switchView.setOn(true, animated: false)
        } else {
            self.switchView.setOn(false, animated: false)
        }
    }
    
    @objc private func toggle() {
        if self.switchView.isOn {
            authenticatedRequest(url: "https://api.gethighlow.com/notifications/" + self.setting + "/on", method: .post, parameters: [:], onFinish: { json in
                if json["error"] != nil {
                    self.switchView.setOn(true, animated: true)
                    alert("An error occurred", "Please try again")
                }
            }, onError: { error in
                self.switchView.setOn(false, animated: true)
                alert("An error occurred", "Please try again")
            })
        } else {
            authenticatedRequest(url: "https://api.gethighlow.com/notifications/" + self.setting + "/off", method: .post, parameters: [:], onFinish: { json in
                if json["error"] != nil {
                    self.switchView.setOn(false, animated: true)
                    alert("An error occurred", "Please try again")
                }
            }, onError: { error in
                self.switchView.setOn(false, animated: true)
                alert("An error occurred", "Please try again")
            })
        }
    }
}


class DailyNotificationSwitchCell: UITableViewCell {
    var switchView: UISwitch = UISwitch()
    
    weak var delegate: DailyNotificationSwitchCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    private func setup() {
        switchView.onTintColor = AppColors.primary
        
        self.textLabel?.text = "Daily Reminder Notification"
        self.accessoryView = switchView
        
        switchView.addTarget(self, action: #selector(switchHandler), for: .valueChanged)
    }
    
    func setSwitch(toState state: Bool) {
        switchView.setOn(state, animated: false)
    }
    
    @objc func switchHandler() {
        self.delegate?.dailyNotification(didSwitchToState: switchView.isOn)
    }
}

protocol DailyNotificationSwitchCellDelegate: AnyObject {
    func dailyNotification(didSwitchToState state: Bool)
}


class TimePickerCell: UITableViewCell {
    
    var timePicker: UIDatePicker = UIDatePicker()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    private func setup() {
        self.contentView.addSubview(timePicker)
        
        timePicker.datePickerMode = .time
        
        
        timePicker.addTarget(self, action: #selector(onDateChange), for: .valueChanged)
        
        timePicker.eqTop(contentView, 5).centerX(contentView)
        
        contentView.bottomAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 5).isActive = true
    }
    
    @objc private func onDateChange() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Reminder"
        content.body = "🌝 Reflect on today and enter a High/Low!"
        
        content.sound = .default
        
        let date = timePicker.date
        
        UserDefaults.standard.set(date, forKey: "com.gethighlow.DailyNotifTime")
        
        var dateComponents = DateComponents()
        
        dateComponents.hour = Calendar.current.component(.hour, from: date)
        dateComponents.minute = Calendar.current.component(.minute, from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)
        
        

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              alert("An error occurred", "We were not able to register a notification for you. Please try again.")
           } else {
            UserDefaults.standard.set(true, forKey: "com.gethighlow.DailyNotif")
            }
        }

        
        
        
        
    }
}
