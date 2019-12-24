//
//  AboutTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/14/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SafariServices
import GoogleSignIn
import Firebase
import UserNotifications

class AboutTableViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var sections: [AboutSection] = [
        AboutSection(title: "Account", options: [
            AboutOption(label: "Log Out", action: #selector(logOut), type: "button")
        ]),
        AboutSection(title: "Feedback", options: [
            AboutOption(label: "Report a bug", action: #selector(reportABug), type: "navigation")
        ]),
        AboutSection(title: "Settings", options: [
            AboutOption(label: "Push Notification Settings", action: #selector(openNotificationSettings), type: "navigation")
        ]),
        AboutSection(title: "Support", options: [
            AboutOption(label: "Our Website", action: #selector(openOurWebsite), type: "button" ),
            AboutOption(label: "Contact Us", action: #selector(openContactUs), type: "button")
        ]),
        AboutSection(title: "Attribution", options: [
            AboutOption(label: "Icons downloaded from Icons8", action: #selector(openIcons8), type: "button")
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutOption", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section].options[indexPath.row].label
        
        if sections[indexPath.section].options[indexPath.row].type == "button" {
            cell.textLabel?.textColor = AppColors.primary
        }
        else if sections[indexPath.section].options[indexPath.row].type == "navigation" {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let slctr = sections[indexPath.section].options[indexPath.row].action {
            self.perform(slctr)
        }
    }
    
    func notAllowedToLogOutAlert() {
        let alert = UIAlertController(title: "Unable to log out", message: "We can't log you out right now due to security issues", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Why not?", style: .default) { action in
            let url = URL(string: "https://gethighlow.com/help/logout.html")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        alert.addAction(alertAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func logOut() {
        let alertController = UIAlertController(title: "Confirm logout?", message: "Do you really want to log out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            
            UNUserNotificationCenter.current().getNotificationSettings() { settings in
                
                if settings.authorizationStatus == .authorized {
            
                    InstanceID.instanceID().instanceID { (result, error) in
                        if error != nil {
                            self.notAllowedToLogOutAlert()
                            return
                        }
                    
                        if let result = result {
                            let token = result.token
                            authenticatedRequest(url: "https://api.gethighlow.com/notifications/deregister/" + token, method: .post, parameters: [:], onFinish: { json in
                                
                                if json["error"] != nil {
                                    self.notAllowedToLogOutAlert()
                                    return
                                }
                                
                                
                                KeychainWrapper.standard.removeObject(forKey: "access")
                                KeychainWrapper.standard.removeObject(forKey: "refresh")
                                KeychainWrapper.standard.removeObject(forKey: "uid")
                                KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                                GIDSignIn.sharedInstance()?.disconnect()
                                switchToAuth()
                                
                            }, onError: { error in
                                self.notAllowedToLogOutAlert()
                            })
                            
                            
                            
                        } else {
                            self.notAllowedToLogOutAlert()
                        }
                    }
                } else {
                    KeychainWrapper.standard.removeObject(forKey: "access")
                    KeychainWrapper.standard.removeObject(forKey: "refresh")
                    KeychainWrapper.standard.removeObject(forKey: "uid")
                    KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                    GIDSignIn.sharedInstance()?.disconnect()
                    switchToAuth()
                }
            }
        }))
    
        
        self.present(alertController, animated: true)
        
    }
    
    @objc func reportABug() {
        let reportBugViewController = storyboard?.instantiateViewController(withIdentifier: "ReportBugViewController") as! ReportBugViewController
        
        self.navigationController?.pushViewController(reportBugViewController, animated: true)
    }
    
    @objc func openNotificationSettings() {
        let notificationSettingsViewController = NotificationsSettingsViewController(style: .grouped)
        
        self.navigationController?.pushViewController(notificationSettingsViewController, animated: true)
    }
    
    @objc func openOurWebsite() {
        let safari = SFSafariViewController(url: URL(string: "https://gethighlow.com")!)
        present(safari, animated: true)
    }
    
    @objc func openContactUs() {
        let safari = SFSafariViewController(url: URL(string: "https://gethighlow.com/contact")!)
        present(safari, animated: true)
    }
    
    @objc func openIcons8() {
        let safari = SFSafariViewController(url: URL(string: "https://icons8.com")!)
        present(safari, animated: true)
    }
    
}
