//
//  UserActivitiesTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit

class UserActivitiesViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "activitySelected" {
            guard let row = message.body as? Int else { return }
            guard row < activities.count else { return }
            let activity = activities[row]
            
            activitySelected(activity)
        } else if message.name == "userSelected" {
            guard let user = self.user else { return }
            self.delegate?.userSelected(user)
        } else if message.name == "submitComment" {
            guard let data = message.body as? NSDictionary else { return }
            guard let commentMessage = data.value(forKey: "message") as? String else { return }
            guard let row = data.value(forKey: "row") as? Int else { return }
            guard row < activities.count else { return }
            let activity = activities[row]
            activity.comment(message: commentMessage, onError: { error in
                printer(error, .error)
            })
        } else if message.name == "moreOptions" {
            guard let data = message.body as? NSDictionary else { return }
            guard let commentid = data.value(forKey: "commentid") as? String else { return }
            guard let message = data.value(forKey: "message") as? String else { return }
            presentCommentMoreOptionsAlert(commentid, message)
        } else if message.name == "flag" {
            guard let row = message.body as? Int else { return }
            guard row < activities.count else { return }
            let activity = activities[row]
            flagActivity(activity)
        } else if message.name == "loadNextPage" {
            currentPage += 1
            loadActivities(page: currentPage)
        }
    }
    
    func flagActivity(_ activity: ActivityResource) {
        if let flagged = activity.flagged, !flagged {
            activity.flag { error in
                alert()
            }
        }
        else {
            activity.unFlag { error in
                alert()
            }
        }
    }
    
    func presentCommentMoreOptionsAlert(_ commentId: String, _ message: String) {
        let _alert = UIAlertController(title: "Options", message: "Select an Action", preferredStyle: .actionSheet)
        _alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            let editCommentViewController = EditCommentViewController()
            editCommentViewController.commentid = commentId
            editCommentViewController.message = message
            self.present(editCommentViewController, animated: true, completion: nil)
        }))
        
        _alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            ActivityService.shared.deleteComment(commentid: commentId, onSuccess: { activity in
            }, onError: { error in
                alert()
            })
        }))
        
        _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(_alert, animated: true, completion: nil)
    }
    
    var webView = ReflectProfileListView()
    
    var user: UserResource? {
        didSet {
            self.loadActivities()
        }
    }
    
    var activities: [ActivityResource] = []
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var currentPage: Int = 0
    
    weak var delegate: UserActivitiesViewControllerDelegate?
    
    override func updateViewColors() {
        themeSwitch(onDark: {
            self.webView.darkMode()
        }, onLight: {
            self.webView.lightMode()
        }, onAuto: {
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.webView.darkMode()
                } else {
                    self.webView.lightMode()
                }
            } else {
                self.webView.lightMode()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "activitySelected")
        userContentController.add(self, name: "userSelected")
        userContentController.add(self, name: "submitComment")
        userContentController.add(self, name: "moreOptions")
        userContentController.add(self, name: "flag")
        userContentController.add(self, name: "loadNextPage")
        config.userContentController = userContentController
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        webView = ReflectProfileListView(frame: .zero, configuration: config)
        
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        self.view.addSubview(webView)
        webView.eqTop(self.view).eqBottom(self.view).eqLeading(self.view).eqTrailing(self.view)
        webView.navigationDelegate = self
        
        webView.load()
        
        webView.scrollView.addSubview(refreshControl)
        self.refreshControl.beginRefreshing()
        loadActivities()
        
        updateViewColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewColors()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateViewColors()
        loadActivities()
    }
    
    @objc func reload() {
        loadActivities()
    }
    
    func activitySelected(_ activity: ActivityResource) {
        if activity.type == "diary" || activity.type == "highlow" {
            if let currentUser = AuthService.shared.uid, let activityOwner = activity.uid {
                if currentUser == activityOwner {
                    let editor = DiaryEditorViewController()
                    editor.activity = activity
                    self.delegate?.activitySelected(activity)
                }
            }
        } else if activity.type == "audio" {
            let editor = RecordAudioDiaryViewController()
            editor.activity = activity
            self.present(editor, animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            guard let url = navigationAction.request.url?.absoluteString else { return }
            openURL(url)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func loadActivities(page: Int = 0) {
        currentPage = page
        user?.getActivities(page: page, onSuccess: { activities in
            if activities.count == 0 {
                self.refreshControl.endRefreshing()
                return
            }
                    
            if page == 0 {
                self.activities = []
            }
            
            let numPages = self.activities.count/10
            if numPages > page + 1 {
                self.activities.removeSubrange((page * 10)..<numPages * 10)
            }
            
            for i in 0..<activities.count {
                self.activities.append(activities[i])
                activities[i].registerReceiver(self, onDataUpdate: self.updateActivity(_:_:))
            }
            
            let json = self.activities.map { activity in
                return activity.asDict()
            }
            
            if page == 0 {
                UserService.shared.getUser(onSuccess: { user in
                    self.refreshControl.endRefreshing()
                    self.updateViewColors()
                    self.webView.loadActivities(json, self.user!.asJson(), user.asJson()) {
                        
                    }
                }, onError: { error in
                    printer(error, .error)
                    self.updateViewColors()
                    self.refreshControl.endRefreshing()
                })
            } else {
                self.updateViewColors()
                self.webView.loadActivities(json, self.user!.asJson()) {
                    self.refreshControl.endRefreshing()
                }
            }
            
        }, onError: { error in
            printer(error, .error)
            alert()
            self.refreshControl.endRefreshing()
        })
    }
    
    func updateActivity(_ sender: UserActivitiesViewController, _ activity: Activity) {
        do {
            let activitiesString = try JSONSerialization.data(withJSONObject: activity.asDict(), options: .prettyPrinted)
            let jsonStr = NSString(data: activitiesString, encoding: String.Encoding.utf8.rawValue)! as String
            webView.evaluateJavaScript("updateActivity(\(jsonStr))")
        } catch(let _) {
            
        }
    }
}

/*
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
*/

protocol UserActivitiesViewControllerDelegate: AnyObject {
    func activitySelected(_ activity: ActivityResource)
    func userSelected(_ user: UserResource)
}
