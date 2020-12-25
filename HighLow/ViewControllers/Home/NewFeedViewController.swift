//
//  NewFeedTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit
import Purchases

class NewFeedViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, SwiftPaywallDelegate {
    
    var feed: [NSDictionary] = []
    
    var webView: ReflectFeedListView = ReflectFeedListView()
    
    var currentPage: Int = 0
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let premiumBanner = UIView()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        //If a user was selected
        if message.name == "userSelected" {
            
            //Get the uid
            guard let uid = message.body as? String else { return }
            
            //Get the user from the uid
            guard let user = findUserInFeed(uid: uid) else { return }
            
            //Now, we open the user's profile
            openProfile(user: user)
        }
        
        //If a comment was submitted...
        else if message.name == "submitComment" {
            
            //Get the data from the message
            guard let data = message.body as? NSDictionary else { return }
            
            //Get the comment message and activityId
            guard let commentMessage = data.value(forKey: "message") as? String else { return }
            guard let activityId = data.value(forKey: "activityId") as? String else { return }
            
            //Get the activity using the activityId
            guard let activity = findActivityInFeed(activityId: activityId) else { return }
            
            activity.comment(message: commentMessage, onError: { error in
                alert()
                printer(error, .error)
            })
        }
        
        //If the user requested more options...
        else if message.name == "moreOptions" {
            
            //Get the data from the message
            guard let data = message.body as? NSDictionary else { return }
            
            //Get the comment id and message
            guard let commentid = data.value(forKey: "commentid") as? String else { return }
            guard let message = data.value(forKey: "message") as? String else { return }
            
            //Present an alert with the options
            presentCommentMoreOptionsAlert(commentid, message)
            
        }
        
        //If the user flagged an activity...
        else if message.name == "flag" {
            
            //Get the activityId
            guard let activityId = message.body as? String else { return }
            
            //Get the activity
            guard let activity = findActivityInFeed(activityId: activityId) else { return }
            
            //Flag the activity
            flagActivity(activity)
            
        }
        
        //If the app needs to load the next page...
        else if message.name == "loadNextPage" {
            
            //Increment the current page
            currentPage += 1
            
            //Load the feed at that page
            getFeed(page: currentPage)
        }
        
    }
    
    func openProfile(user: UserResource) {
        
        //Create a new profile view controller
        let profileViewController = NewProfileViewController()
        
        //Set the user
        profileViewController.user = user
        
        //Push the view controller to the navigation stack
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func findUserInFeed(uid: String) -> UserResource? {
        
        //For every item in the feed...
        for item in feed {
            
            //If the type is 'activity', and the user has the uid we asked for...
            if let type = item.value(forKey: "type") as? String, type == "activity", let user = item.value(forKey: "user") as? UserResource, user.uid == uid {
                
                //Return the user
                return user
                
            }
        }
        
        //If we get through the list and haven't found the user yet, we return nil
        return nil
    }

    func findActivityInFeed(activityId: String) -> ActivityResource? {
        
        //For every item in the feed...
        for item in feed {
            
            //If the type is 'activity', and the activity has the activityId we asked for...
            if let type = item.value(forKey: "type") as? String, type == "activity", let activity = item.value(forKey: "activity") as? ActivityResource, activity.activityId == activityId {
                
                //Return the activity
                return activity
                
            }
        }
        
        //If we get through the list and haven't found the activity yet, we return nil
        return nil
    }

    func presentCommentMoreOptionsAlert(_ commentId: String, _ message: String) {
        
        //Create an alert
        let _alert = UIAlertController(title: "Options", message: "Select an Action", preferredStyle: .actionSheet)
        
        //Add the "edit" action to the alert
        _alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            
            //If the users decides to edit the comment, create the edit comment view controller
            let editCommentViewController = EditCommentViewController()
            
            //Set the comment id
            editCommentViewController.commentid = commentId
            
            //Set the message
            editCommentViewController.message = message
            
            //Present the editCommentViewController
            self.present(editCommentViewController, animated: true, completion: nil)
        }))
        
        //Add the "delete" action to the alert
        _alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            //If the user decides to delete the comment, make a request to delete it
            ActivityService.shared.deleteComment(commentid: commentId, onSuccess: { activity in
            }, onError: { error in
                alert()
            })
        }))
        
        //Add the "cancel" action to the alert
        _alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Present the alert
        self.present(_alert, animated: true, completion: nil)
    }
    
    func flagActivity(_ activity: ActivityResource) {
        
        //If the activity is not already flagged...
        if let flagged = activity.flagged, !flagged {
            
            //Flag the activity
            activity.flag { error in
                alert()
            }
        }
        
        //Otherwise...
        else {
            
            //Unflag the activity
            activity.unFlag { error in
                alert()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewColors()
    }
    
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
        
        self.navigationController?.navigationBar.barTintColor = getColor("TabBar")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateViewColors()
        getFeed()
    }
    
    func purchaseCompleted(paywall: SwiftPaywall, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo) {
        showOrHidePremiumBanner()
    }
    
    func purchaseRestored(paywall: SwiftPaywall, purchaserInfo: Purchases.PurchaserInfo?, error: Error?) {
        showOrHidePremiumBanner()
    }
    
    var webViewTopConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        
        let imageView = UIImageView(image: UIImage(named: "Premium"))
        let premiumLabel = UILabel()
        premiumLabel.text = "Upgrade to Premium for Unlimited Features!"
        premiumLabel.textColor = .white
        premiumLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        premiumBanner.backgroundColor = AppColors.primary
        
        premiumBanner.addSubviews([imageView, premiumLabel])
        
        imageView.eqTop(premiumBanner, 10).eqLeading(premiumBanner, 7).width(30).aspectRatioFromWidth(1)
        premiumLabel.leadingToTrailing(imageView, 10).centerY(imageView)
        
        self.view.addSubview(premiumBanner)
        
        premiumBanner.eqTop(self.view.safeAreaLayoutGuide).eqLeading(self.view.safeAreaLayoutGuide).eqTrailing(self.view.safeAreaLayoutGuide).eqBottom(imageView, 7)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(showPaywall))
        premiumBanner.addGestureRecognizer(tapper)
        
        //Create a configuration object for the webview
        let config = WKWebViewConfiguration()
        
        //Create a userContentController for the webview
        let userContentController = WKUserContentController()
        
        //Add the necessary message handlers
        userContentController.add(self, name: "userSelected")
        userContentController.add(self, name: "submitComment")
        userContentController.add(self, name: "moreOptions")
        userContentController.add(self, name: "flag")
        userContentController.add(self, name: "loadNextPage")
        
        //Set the userContentController on the config object
        config.userContentController = userContentController
        
        //Allow file access from file urls
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        //Enable JavaScript
        config.preferences.javaScriptEnabled = true
        
        //Create the webview using the config
        webView = ReflectFeedListView(frame: .zero, configuration: config)
        
        //Add the refreshControl target
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        //Add the refreshControl to the webview scrollView
        webView.scrollView.addSubview(refreshControl)
        
        //Add the webview to the view
        self.view.addSubview(webView)
        
        //Pin the webview to all four sides
        webView.eqBottom(self.view).eqLeading(self.view).eqTrailing(self.view)
        
        webViewTopConstraint = webView.topAnchor.constraint(equalTo: premiumBanner.bottomAnchor)
        webViewTopConstraint?.isActive = true
        
        showOrHidePremiumBanner()
        
        //Set the webview navigation delegate
        webView.navigationDelegate = self
        
        //Load the webview
        webView.load()
        
        //Update the colors
        updateViewColors()
        
        //Get the feed data
        getFeed()
        
    }
    
    @objc func showPaywall() {
        let paywall = getPaywall()
        paywall.delegate = self
        self.present(paywall, animated: true, completion: nil)
    }
    
    func showOrHidePremiumBanner() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["Premium"]?.isActive == true {
                self.webViewTopConstraint?.isActive = false
                self.webViewTopConstraint = self.webView.topAnchor.constraint(equalTo: self.view.topAnchor)
                self.webViewTopConstraint?.isActive = true
            } else {
                self.premiumBanner.isHidden = false
            }
        }
    }
    
    @objc func reload() {
        //Get the feed again
        getFeed()
    }
    
    func getFeed(page: Int = 0) {
        
        //Indicate that we are loading
        refreshControl.beginRefreshing()
        
        //Set the currentPage to the one being loaded
        currentPage = page
        
        //Make the network request to get the feed
        UserService.shared.getFeed(page: page, onSuccess: { feedArr in
            
            //If the feed page is empty, return
            if feedArr.count == 0 {
                self.refreshControl.endRefreshing()
                return
            }
            
            print(feedArr)
            
            //If it's the first page, reset the feed
            if page == 0 {
                self.feed = []
            }
            
            //Get the number of pages already loaded
            let numPages = self.feed.count/10
            
            //If we're loading a page less than the number we've already loaded, remove the items after this page
            if numPages > page + 1 {
                self.feed.removeSubrange((page * 10)..<numPages * 10)
            }
            
            //Go through all the feed items
            for i in 0..<feedArr.count {
                
                //If the item has type "activity"...
                if let type = feedArr[i].value(forKey: "type") as? String, type == "activity"{
                    
                    //If the activity exists...
                    if let activity = feedArr[i].value(forKey: "activity") as? ActivityResource {
                        
                        //Register a receiver on the activity
                        activity.registerReceiver(self, onDataUpdate: self.updateActivity(_:_:))
                    }
                    
                }
                
                //Add the item to the feed array
                self.feed.append(feedArr[i])
            }
            
            
            //If we're loading the first page...
            if page == 0 {
                //...also get the current user and feed that to the webview
                UserService.shared.getUser(onSuccess: { user in
                    self.updateViewColors()
                    self.webView.loadFeed(self.feed, user.asJson()) {
                        self.refreshControl.endRefreshing()
                    }
                }, onError: { error in
                    printer(error, .error)
                    self.refreshControl.endRefreshing()
                })
            } else {
                self.updateViewColors()
                self.webView.loadFeed(self.feed) {
                    self.refreshControl.endRefreshing()
                }
            }
            
        }, onError: { error in
            alert()
            self.refreshControl.endRefreshing()
        })
    }
    
    func updateActivity(_ sender: NewFeedViewController, _ activity: Activity) {
        do {
            //Convert the activity to a JSON string
            let activitiesString = try JSONSerialization.data(withJSONObject: activity.asDict(), options: .prettyPrinted)
            let jsonStr = NSString(data: activitiesString, encoding: String.Encoding.utf8.rawValue)! as String
            
            //Send the converted JSON string to the webview to update
            webView.evaluateJavaScript("updateActivity(\(jsonStr))")
        } catch(let error) {
            printer(error, .error)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        //If a link is clicked, open it in safari
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            guard let url = navigationAction.request.url?.absoluteString else { return }
            openURL(url)
        } else {
            decisionHandler(.allow)
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
