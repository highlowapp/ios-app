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
import PopupDialog
import Crisp

class AboutTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView = UITableView()
    
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
            AboutOption(label: "Push Notification Settings", action: #selector(openNotificationSettings), type: "navigation"),
            AboutOption(label: "Theme", action: #selector(void), type: "theme")
        ]),
        AboutSection(title: "Support", options: [
            AboutOption(label: "Our Website", action: #selector(openOurWebsite), type: "button" ),
            AboutOption(label: "Contact Us", action: #selector(openContactUs), type: "button")
        ]),
        AboutSection(title: "Agreements", options: [
            AboutOption(label: "Privacy Policy", action: #selector(openPrivacyPolicy), type: "button"),
            AboutOption(label: "Terms of Service", action: #selector(openTermsOfService), type: "button")
        ]),
        AboutSection(title: "Attribution", options: [
            AboutOption(label: "Icons downloaded from Icons8", action: #selector(openIcons8), type: "button")
        ])
    ]
    
    override func updateViewColors() {
        tableView.visibleCells.forEach({ cell in
            cell.backgroundColor = getColor("White2Black")
            let indexPath = tableView.indexPath(for: cell)!
            
            if sections[indexPath.section].options[indexPath.row].type == "button" {
                cell.textLabel?.textColor = AppColors.primary
            } else {
                cell.textLabel?.textColor = getColor("BlackText")
            }
        })
        self.view.backgroundColor = getColor("White2Black")
        tabBarController?.tabBar.barTintColor = getColor("White2Black")
        
        for section in 0...tableView.numberOfSections {
            tableView.headerView(forSection: section)?.contentView.backgroundColor = getColor("Separator")
            tableView.headerView(forSection: section)?.textLabel?.textColor = getColor("BlackText")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        updateViewColors()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        
        view.addSubview(tableView)
        
        tableView.eqLeading(view).eqTrailing(view).eqTop(view).eqBottom(view)
        
        let crispIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        crispIcon.setImage(UIImage(named: "Crisp"), for: .normal)
        crispIcon.backgroundColor = AppColors.primary
        crispIcon.layer.cornerRadius = 30
        
        crispIcon.layer.shadowColor = UIColor.black.cgColor
        crispIcon.layer.shadowRadius = 3
        crispIcon.layer.shadowOpacity = 0.3
        crispIcon.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        crispIcon.addTarget(self, action: #selector(startChat), for: .touchUpInside)
        
        view.addSubview(crispIcon)
        
        crispIcon.eqTrailing(view.safeAreaLayoutGuide, -10).eqBottom(view.safeAreaLayoutGuide, -10).width(60).height(60)
        
        view.bringSubviewToFront(crispIcon)
                
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func startChat() {
        self.present(ChatViewController(), animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.headerView(forSection: section)?.contentView.backgroundColor = getColor("Separator")
        tableView.headerView(forSection: section)?.textLabel?.textColor = getColor("BlackText")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections[indexPath.section].options[indexPath.row].type == "theme" {
            let cell = ThemeControlTableViewCell()
            cell.backgroundColor = getColor("White2Black")
            cell.textLabel?.textColor = getColor("BlackText")
            return cell
        }
        let cell = UITableViewCell()
        cell.backgroundColor = getColor("White2Black")
        cell.textLabel?.text = sections[indexPath.section].options[indexPath.row].label
        cell.textLabel?.textColor = getColor("BlackText")
        
        if sections[indexPath.section].options[indexPath.row].type == "button" {
            cell.textLabel?.textColor = AppColors.primary
        }
        else if sections[indexPath.section].options[indexPath.row].type == "navigation" {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let slctr = sections[indexPath.section].options[indexPath.row].action {
            self.perform(slctr)
        }
    }
    
    func notAllowedToLogOutAlert() {
        let popup = PopupDialog(title: "Unable to log out", message: "We can't log you out right now due to security")
        popup.addButtons([
            DefaultButton(title: "Why not?") {
                let url = URL(string: "https://gethighlow.com/help/logout.html")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            CancelButton(title: "OK", action: nil)
        ])
        
        self.present(popup, animated: true)
    }
    
    @objc func logOut() {
        let popup = PopupDialog(title: "Confirm logout?", message: "Do you really want to log out?")
        popup.addButtons([
            DestructiveButton(title: "Confirm") {
                
                UNUserNotificationCenter.current().getNotificationSettings() { settings in
                    
                    if settings.authorizationStatus == .authorized {
                
                        InstanceID.instanceID().instanceID { (result, error) in
                            if error != nil {
                                self.notAllowedToLogOutAlert()
                                return
                            }
                        
                            if let result = result {
                                let token = result.token
                                authenticatedRequest(url: "/notifications/deregister/" + token, method: .post, parameters: [:], onFinish: { json in
                                    
                                    if json["error"] != nil {
                                        self.notAllowedToLogOutAlert()
                                        return
                                    }
                                    
                                    
                                    KeychainWrapper.standard.removeObject(forKey: "access")
                                    KeychainWrapper.standard.removeObject(forKey: "refresh")
                                    KeychainWrapper.standard.removeObject(forKey: "uid")
                                    KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                                    UserDefaults.standard.removeObject(forKey: "com.gethighlow.hasAgreedToTerms")
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
                        UserDefaults.standard.removeObject(forKey: "com.gethighlow.hasAgreedToTerms")
                        GIDSignIn.sharedInstance()?.disconnect()
                        switchToAuth()
                    }
                }
            },
            CancelButton(title: "Cancel", action: nil)
        ])
        
        self.present(popup, animated: true)
        
    }
    
    @objc func void() {
        
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
        openURL("https://gethighlow.com")
        /*
        let safari = SFSafariViewController(url: URL(string: "https://gethighlow.com")!)
        present(safari, animated: true)
        */
    }
    
    @objc func openContactUs() {
        openURL("https://gethighlow.com/contact")
        /*
        let safari = SFSafariViewController(url: URL(string: "https://gethighlow.com/contact")!)
        present(safari, animated: true)
         */
    }
    
    func openURL(_ url: String) {
        guard let url = URL(string: url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func openIcons8() {
        openURL("https://icons8.com")
        /*
        let safari = SFSafariViewController(url: URL(string: "https://icons8.com")!)
        present(safari, animated: true)
         */
    }
    
    @objc func openPrivacyPolicy() {
        openURL("https://gethighlow.com/privacy")
    }
    @objc func openTermsOfService() {
        openURL("https://gethighlow.com/eula")
    }
    
}
