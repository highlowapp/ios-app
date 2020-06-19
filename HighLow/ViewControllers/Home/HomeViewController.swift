//
//  HomeViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/10/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging


class HomeViewController: UITableViewController, HighLowViewDelegate, EditHLDelegate, UITextViewDelegate, ShowAllCommentsViewCellDelegate, CommentViewCellDelegate, EditCommentViewControllerDelegate {
    
    func openImageFullScreen(viewController: ImageFullScreenViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    let loader: HLLoaderView = HLLoaderView()
    
    var commentsAreCollapsed: Bool = true
    
    var date: String?
    
    weak var delegate: HomeViewControllerDelegate?
    
    var shouldScroll: Bool = true
    
    var comments: [[String: Any]] = []
    let maxComments = 3
    
    var editable: Bool = true {
        didSet {
            self.highLowView.editable = self.editable
        }
    }
    
    var highlow: HighLow = .empty
    
    var commentTextViewHasChanged: Bool = false
    let commentInput: UITextView = UITextView()
    let sendButton: UIView = UIView()
    let inputWrapper: UIView = UIView()
    
    //EditHLDelegate methods
    func didFinishEditingHL(data: NSDictionary) {
    
        if let hli = data["highlowid"] as? String {
            self.highlow.highlowid = hli
        }
        
        getHighLow()
        
    }
    
    
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 
        guard let footerView = tableView.tableFooterView else {
            return
        }
 
        let footerSize = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if footerView.frame.size.height != footerSize.height {
            footerView.frame.size.height = footerSize.height
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
        
       
 
    }
    
    
    
    //HighLowViewDelegate methods
    func willEditHigh(sender: HighLowView) {
        showEditor(type: "high")
    }
    
    func willEditLow(sender: HighLowView) {
        showEditor(type: "low")
    }
    
    func didFinishUpdatingContent(sender: HighLowView) {
        loader.stopLoading()
        loader.removeFromSuperview()
        
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableFooterView?.layoutIfNeeded()
        
        tableView.layoutIfNeeded()
        
        tableView.reloadData()
    }
    
    func updateHighLow(with: [String : Any]) {
        highlow.update(with: with)
        NotificationCenter.default.post(name: Notification.Name("highLowUpdate"), object: nil, userInfo: highlow.asJson() as? [AnyHashable : Any])
    }
    
    

    var highLowView: HighLowView = HighLowView()
    
    var highlowid: String?
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                
                InstanceID.instanceID().instanceID { (result, error) in
                    if let fcmToken = result?.token {
                        
                        let params: [String: Any] = [
                            "platform": 0,
                            "device_id": fcmToken
                        ]
                        
                        authenticatedRequest(url: "/notifications/register", method: .post, parameters: params, onFinish: { json in
                        }, onError: { error in
                            
                        })
                        
                    }
                }
                
                
            } else {
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    override func updateViewColors() {
        self.view.backgroundColor = getColor("White2Black")
        inputWrapper.backgroundColor = getColor("White2Gray")
        commentInput.textColor = getColor("GrayText")
        highLowView.updateColors()
        tableView.visibleCells.forEach({ cell in
            cell.updateColors()
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    override func viewDidLoad() {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        super.viewDidLoad()
        handleDarkMode()
                
        tableView.tableHeaderView = UIView()
        tableView.tableHeaderView?.accessibilityIdentifier = "tableHeaderView"
        shouldBeEditable()
        
        tableView.register(ShowAllCommentsViewCell.self, forCellReuseIdentifier: "ShowComments")
        //tableView.register(CommentViewCell.self, forCellReuseIdentifier: "CommentViewCell")

        
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Request permission to send push notifications
        registerForPushNotifications()
        

        self.navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = AppColors.primary
        navigationController?.navigationBar.isTranslucent = false
        
        highLowView.editable = self.editable
        highLowView.accessibilityIdentifier = "highLowView"
        
        
        tableView.tableHeaderView!.addSubview(highLowView)
        tableView.tableHeaderView!.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        highLowView.eqTop(tableView.tableHeaderView!, 10).eqWidth(tableView.tableHeaderView!, -20).centerX(tableView.tableHeaderView!)
        
        //Divider
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.accessibilityIdentifier = "divider"
        
        tableView.tableHeaderView!.addSubview(divider)
        
        //Constraints
        divider.centerX(self.view).eqWidth(self.view).height(1).topToBottom(highLowView)
                
        //Comment view
        let commentView = UIView()
        commentView.translatesAutoresizingMaskIntoConstraints = false
        commentView.accessibilityIdentifier = "commentView"
        
        let profileContainerView = UIView()
        profileContainerView.layer.cornerRadius = 25
        profileContainerView.layer.shadowColor = UIColor.black.cgColor
        profileContainerView.layer.shadowRadius = 1
        profileContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        profileContainerView.layer.shadowOpacity = 0.2
        
        let profileImage = HLImageView(frame: .zero)
        profileImage.layer.cornerRadius = 25
        profileImage.accessibilityIdentifier = "profileImage"
        
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        profileContainerView.addSubview(profileImage)
        commentView.addSubview(profileContainerView)
        
        profileContainerView.leadingAnchor.constraint(equalTo: commentView.leadingAnchor, constant: 10).isActive = true
        profileContainerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        profileImage.eqWidth(profileContainerView).eqHeight(profileContainerView).centerX(profileContainerView).centerY(profileContainerView)
        
        //Get the profile image
        authenticatedRequest(url: "/user/get/profileimage", method: .post, parameters: [:], onFinish: { json in
            
            //All we want is the UID
            if let imageURL = json["profileimage"] as? String {
                
                var url = imageURL
                
                if !imageURL.starts(with: "http") {
                    url = "https://storage.googleapis.com/highlowfiles/" + imageURL
                }
                profileImage.loadImageFromURL(url)
            }
                
            else {
                alert("An error occurred", "Try closing and reopening the app")
            }
            
        }, onError: { (error) in
            
            alert("An error occurred", "Try closing and reopening the app")
            
        })
        
        
        //tableView scroll keyboard dismiss
        tableView.keyboardDismissMode = .onDrag
        
        
        
        
        //Input box
        inputWrapper.showBorder(AppColors.primary, 1)
        inputWrapper.layer.cornerRadius = 5
        inputWrapper.clipsToBounds = true
        inputWrapper.accessibilityIdentifier = "inputWrapper"
        
        
        commentView.addSubview(inputWrapper)
        
        inputWrapper.eqTop(commentView, 20).leadingToTrailing(profileImage, 10).eqTrailing(commentView, -10)
        
        commentInput.text = "Leave a comment..."
        commentInput.isScrollEnabled = false
        commentInput.isEditable = true
        commentInput.delegate = self
        commentInput.font = UIFont.systemFont(ofSize: 15)
        
        commentInput.accessibilityIdentifier = "commentInput"
        commentInput.backgroundColor = .none
        
        inputWrapper.addSubview(commentInput)
        
        commentInput.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.eqTop(inputWrapper)
        commentInput.eqTop(inputWrapper, 5).eqLeading(inputWrapper, 5)
        
        sendButton.backgroundColor = AppColors.primary
        sendButton.accessibilityIdentifier = "sendButton"
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(sendComment))
        
        sendButton.addGestureRecognizer(tapper)
        
        inputWrapper.addSubview(sendButton)
        
        sendButton.leadingToTrailing(commentInput, 5).eqTrailing(inputWrapper).eqTop(inputWrapper).eqBottom(inputWrapper).eqHeight(inputWrapper).width(50)
        
        let sendImg = UIImageView(image: UIImage(named: "send-white"))
        sendImg.contentMode = .scaleAspectFit
        
        sendImg.accessibilityIdentifier = "sendImg"
        
        sendButton.addSubview(sendImg)
        
        sendImg.centerX(sendButton).centerY(sendButton).width(20).height(20)
        
        inputWrapper.eqBottom(commentInput, 7)
        commentView.eqBottom(inputWrapper, 20)
        
        tableView.tableHeaderView!.bottomAnchor.constraint(equalTo: divider.bottomAnchor).isActive = true
        
        
        
        
        
        let commentContainer = UIView()
        commentContainer.accessibilityIdentifier = "commentContainer"
        commentContainer.layer.cornerRadius = 25
        commentContainer.layer.shadowColor = UIColor.black.cgColor
        commentContainer.layer.shadowRadius = 2
        commentContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        commentContainer.layer.shadowOpacity = 0.2
        
        
        
        //Footer
        tableView.tableFooterView = UIView()
        tableView.tableFooterView!.addSubview(commentContainer)
        tableView.tableFooterView!.clipsToBounds = true
        tableView.tableFooterView?.accessibilityIdentifier = "tableFooterView"
        
        commentContainer.eqLeading(tableView.tableFooterView!).eqTrailing(tableView.tableFooterView!).eqTop(tableView.tableFooterView!)
        
        tableView.tableFooterView!.bottomAnchor.constraint(equalTo: commentContainer.bottomAnchor).isActive = true
        
        commentContainer.addSubview(commentView)
        
        commentView.eqWidth(self.view).eqTop(commentContainer).eqLeading(self.view).eqTrailing(self.view)
        commentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        commentContainer.eqBottom(commentView)        
        
        //HighLowView delegate
        highLowView.delegate = self
        
        highLowView.updateContent(highlow.asJson())
        
        updateViewColors()
        
        getHighLow()
        
        
        let hasSeenDarkMode = UserDefaults.standard.bool(forKey: "com.gethighlow.hasSeenDarkMode")
        
        if !hasSeenDarkMode {
            perform(#selector(presentDarkMode), with: nil, afterDelay: 1)
        }
        
    }
    
    @objc func presentDarkMode() {
        let viewController = DarkModeViewController()
        self.present(viewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func shouldBeEditable() {
        
        getUid(callback: { uid in
            if uid == self.highlow.uid {
                
                self.editable = true
                
            } else {
                self.editable = false
            }
            
        })
            
    }
    
    
    
    
    
    func showEditor(type: String) {
        let editorViewController = EditHLViewController()
        editorViewController.delegate = self
        editorViewController.highlowid = highlow.highlowid
        editorViewController.type = type
        
        if editorViewController.type == "high" {
            editorViewController.content = highlow.high ?? ""
        } else {
            editorViewController.content = highlow.low ?? ""
        }
        
        if highlow.date != nil {
            if highlow.date == "" {
                editorViewController.date = getTodayDateStr()
            } else {
                editorViewController.date = highlow.date
            }
        }
        
        var highlow_image = (type == "high") ? highlow.highImage:highlow.lowImage
        
        highlow_image = highlow_image ?? nil
        
        if let img = highlow_image {
            if img != "" {
                editorViewController.imageURL = "https://storage.googleapis.com/highlowfiles/" + type + "s/" + img
            }
        }
        
        self.present(editorViewController, animated: true, completion: nil)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !commentTextViewHasChanged {
            commentInput.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !commentTextViewHasChanged {
            commentInput.text = "Leave a comment..."
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            commentTextViewHasChanged = true
        }
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        tableView.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        
    }
    
    
    func getHighLow() {
        
        loader.translatesAutoresizingMaskIntoConstraints = false
    
        self.view.addSubview(loader)
        
        loader.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        loader.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        loader.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        loader.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        loader.startLoading()
        if highlow.highlowid == "" || highlow.highlowid == nil {
            if highlow.date == "" || highlow.date == nil {
                
                
                
                let parameters: [String: String] = [
                    "date": getTodayDateStr()
                ]
                
                authenticatedRequest(url: "/highlow/get/date", method: .post, parameters: parameters, onFinish: { (JSON) in
                    //The request was successful! Now get the data from the High/Low and fill out the High/Low view
                    if let hli = JSON["highlowid"] as? String {
                        self.highlow.highlowid = hli
                        self.highLowView.date = JSON["_date"] as? String
                        self.highLowView.highlowid = hli
                        self.highlow = HighLow(data: JSON)
                        
                        self.tableView.reloadData()
                        
                    }
                    
                    if let uid = JSON["uid"] as? String {
                        self.highlow.uid = uid
                    }
                    
                    self.shouldBeEditable()
                    
                    self.refreshControl?.endRefreshing()
                    
                    
                    self.highLowView.updateContent(JSON)
                    
                    self.highLowView.setLikeFlag(liked: JSON["liked"] as? Int, totalLikes: JSON["total_likes"] as? Int, flagged: JSON["flagged"] as? Int)
                    
                    
                }, onError: { (error) in
                    
                    alert("An error occurred", "Please try closing the app and opening it again")
                    self.refreshControl?.endRefreshing()
                    
                })
            } else {
                let params: [String: String] = [
                    "date": highlow.date!
                ]
                authenticatedRequest(url: "/highlow/get/date", method: .post, parameters: params, onFinish: { (JSON) in
                    //The request was successful! Now get the data from the High/Low and fill out the High/Low view
                    if let hli = JSON["highlowid"] as? String {
                        self.highlow.highlowid = hli
                        self.highLowView.date = JSON["_date"] as? String
                        self.highLowView.highlowid = hli
                        self.highlow = HighLow(data: JSON)
                        
                        self.tableView.reloadData()
                    }
                    
                    if let uid = JSON["uid"] as? String {
                        self.highlow.uid = uid
                    }
                    
                    self.shouldBeEditable()
                    
                    self.refreshControl?.endRefreshing()
                    
                    
                    
                    self.highLowView.updateContent(JSON)
                    self.highLowView.setLikeFlag(liked: JSON["liked"] as? Int, totalLikes: JSON["total_likes"] as? Int, flagged: JSON["flagged"] as? Int)
                    
                    
                    
                }, onError: { (error) in
                    
                    alert("An error occurred", "Please try closing the app and opening it again")
                    self.refreshControl?.endRefreshing()
                    
                })
                
            }
        } else {

            authenticatedRequest(url: "/highlow/" + self.highlow.highlowid!, method: .get, parameters: [:], onFinish: { json in
                
                if (json["error"] as? String) != nil {
                    alert("An error occurred", "Please try closing the app and opening it again.")
                    self.refreshControl?.endRefreshing()
                    self.loader.stopLoading()
                } else {
                    
                    self.highLowView.date = json["_date"] as? String
                    self.highLowView.highlowid = self.highlow.highlowid
                    self.highlow = HighLow(data: json)
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                
                if let uid = json["uid"] as? String {
                    self.highlow.uid = uid
                }
                
                self.shouldBeEditable()
                

                self.highLowView.updateContent(json)
                self.highLowView.setLikeFlag(liked: json["liked"] as? Int, totalLikes: json["total_likes"] as? Int, flagged: json["flagged"] as? Int)
                
            }, onError: { error in
                self.loader.stopLoading()
                alert("An error occurred", "Please try closing the app and opening it again")
                self.refreshControl?.endRefreshing()
                
            })
            
        }
        
        
        
        //self.highLowView.editable = true
        
    }
    
    

}

//Sending comments
extension HomeViewController {
    
    @objc func sendComment() {
        
        if commentTextViewHasChanged && commentInput.text != "" {
            let loader = UIActivityIndicatorView(style: .white)
            loader.translatesAutoresizingMaskIntoConstraints = false
            loader.hidesWhenStopped = true
            
            sendButton.addSubview(loader)
            
            loader.backgroundColor = AppColors.primary
            loader.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor).isActive = true
            loader.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
            loader.widthAnchor.constraint(equalTo: sendButton.widthAnchor).isActive = true
            
            
            
            loader.startAnimating()
            
            
            //Here we take the text from the textView, and send it to the API
            let text = commentInput.text
            
            let parameters: [String: String] = [
                "message": text ?? "",
                "request_id": UUID().uuidString
            ]
            
            if let hli = highlow.highlowid {
            
                authenticatedRequest(url: "/highlow/comment/" + hli, method: .post, parameters: parameters, onFinish: { json in
                    
                    //Do something with the response
                    loader.stopAnimating()
                    
                    self.getHighLow()
                    
                }) { error in
                    loader.stopAnimating()
                    alert("An error occurred", "Please try again")
                    
                }
                
            } else {
                loader.stopAnimating()
                alert("Whoops!", "You have to enter either a High or a Low before commenting")
            }
            
            
            self.commentInput.textColor = .darkGray
            self.commentInput.text = "Leave a comment"
            commentTextViewHasChanged = false
        } else {
            alert("Whoops!", "You have to enter a comment first")
            commentTextViewHasChanged = false
        }
    }
    
}


//tableView stuff
extension HomeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comments = highlow.comments 
        if commentsAreCollapsed {
            return min(comments.count, maxComments) + 1
        }
        
        else if comments.count > 0 {
            return comments.count + 1
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comments = highlow.comments 
        if commentsAreCollapsed && indexPath.row + 1 > min(comments.count, maxComments) {
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.delegate = self
            cell.setState(!commentsAreCollapsed)
            return cell
        } else if !commentsAreCollapsed && indexPath.row + 1 > comments.count {
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.delegate = self
            cell.setState(!commentsAreCollapsed)
            return cell
        } else if comments.count == 0 {
            //let cell = ShowAllCommentsViewCell(style: .default, reuseIdentifier: "ShowComments")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowComments", for: indexPath) as! ShowAllCommentsViewCell
            cell.delegate = self
            cell.setState(!commentsAreCollapsed)
            return cell
        } else {
        
            //let cell = tableView.dequeueReusableCell(withIdentifier: "CommentViewCell", for: indexPath) as! CommentViewCell
            let comment = comments[indexPath.row]
            
            let cell = CommentViewCell(comment: comment)
            
            
            //cell.updateContent(imageURL: comment.profileimage!, firstname: comment.firstname!, lastname: comment.lastname!, timestamp: comment._timestamp!, message: comment.message!)
            cell.delegate = self
            cell.uid = comment.uid!
            cell.commentid = comment.commentid!

            
            return cell
        }
        
        
    }
    
    
    func showAll(sender: ShowAllCommentsViewCell) {
        commentsAreCollapsed = false
        tableView.reloadData()
    }
    
    func collapse(sender: ShowAllCommentsViewCell) {
        
        commentsAreCollapsed = true
        tableView.reloadData()
        
    }
    
    
    
    @objc func refresh() {
        getHighLow()
    }
    
    
    
    //Fetching comments (deprecated)
    func getComments() {
        
        if let hli = highlow.highlowid {
            
            //Let's go get those comments
            authenticatedRequest(url: "/highlow/get_comments/" + hli, method: .get, parameters: [:], onFinish: { json in
                
                if (json["error"] as? String) != nil {
                    //Do something with the error
                    alert("Could not fetch comments", "An error has occurred")
                    self.refreshControl?.endRefreshing()
                }
                
                else {
                    
                    //Load the comments and reload the tableView
                    self.comments = json["comments"] as! [[String: Any]]
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                
                
            }, onError: { error in
                
                alert("Could not fetch comments", "An error has occurred")
                self.refreshControl?.endRefreshing()
                
            })
            
        } else {
            //Just give up
            self.refreshControl?.endRefreshing()
            return
        }
        
    }
    
}



//CommentViewCellDelegate methods
extension HomeViewController {
    
    
    func willEditComment(sender: CommentViewCell) {
        let editCommentViewController = EditCommentViewController()
        editCommentViewController.commentid = sender.commentid
        editCommentViewController.message = sender.messageLabel.text
        editCommentViewController.delegate = self
        self.present(editCommentViewController, animated: true)
    }
    
    func hasDeletedComment(sender: CommentViewCell) {
        getComments()
    }
    
    
    func editCommentViewControllerDidFinishEditing(sender: EditCommentViewController) {
        getComments()
    }
    
}


extension HomeViewController {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            self.delegate?.hasBeenRemovedFromParent?(sender: self)
        }
        
    }
}


@objc protocol HomeViewControllerDelegate: AnyObject {
    @objc optional func hasBeenRemovedFromParent(sender: HomeViewController)
}
