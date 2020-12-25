//
//  NewProfileTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/11/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class NewProfileViewController: UIViewController {
    
    var user: UserResource? {
        didSet {
            loadUser()
        }
    }
    
    let pageView: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let header: UIView = UIView()
    
    let profileImageView: HLRoundImageView = HLRoundImageView(frame: .zero)
    let nameLabel: UILabel = UILabel()
    let bioLabel: UILabel = UILabel()
    let tabs: UIStackView = UIStackView()
    
    let activitiesVC = UserActivitiesViewController()
    let friendsVC = FriendsCollectionViewController()
    
    let activitiesTab = TabView()
    let friendsTab = TabView()
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            setupPager()
        }
    }
    
    var headerTopConstraint: NSLayoutConstraint?
    
    var shouldShowFriendsFirst: Bool = false
    
    override func updateViewColors() {
        header.backgroundColor = getColor("TabBar")
        pageView.view.backgroundColor = getColor("Separator")
        nameLabel.textColor = getColor("BlackText")
        bioLabel.textColor = getColor("BlackText")
        activitiesVC.updateViewColors()
        friendsVC.updateViewColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        pageView.willMove(toParent: self)
        self.view.addSubviews([header, pageView.view])
        header.backgroundColor = .white
        headerTopConstraint = header.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        headerTopConstraint?.isActive = true
        
        self.title = "Profile"
        
        header.eqLeading(self.view).eqTrailing(self.view)
        
        pageView.view.topToBottom(header).eqLeading(self.view).eqTrailing(self.view).eqBottom(self.view)
        pageView.view.backgroundColor = rgb(240, 240, 240)
        
        header.addSubviews([profileImageView, nameLabel, bioLabel, tabs])
        
        profileImageView.centerX(header).eqTop(header, 20).width(130).aspectRatioFromWidth(1)
        
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        nameLabel.text = "Your Name"
        nameLabel.textAlignment = .center
        bioLabel.font = .preferredFont(forTextStyle: .body)
        bioLabel.text = "Your bio"
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        
        let editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(AppColors.primary, for: .normal)
        editButton.isHidden = true
        editButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        
        header.addSubview(editButton)
        
        editButton.eqTrailing(header, -40).eqTop(header, 20)
        nameLabel.centerX(header).topToBottom(profileImageView, 20)
        bioLabel.centerX(header).topToBottom(nameLabel).eqWidth(header, 0, 0.8)
        
        tabs.eqLeading(header).eqTrailing(header).height(50).topToBottom(bioLabel, 20)
        
        activitiesTab.title = "Activities"
        activitiesTab.isSelected = true
        
        friendsTab.title = "Friends"
        tabs.addArrangedSubview(activitiesTab)
        tabs.addArrangedSubview(friendsTab)
        
        let tapper1 = UITapGestureRecognizer(target: self, action: #selector(viewActivities))
        let tapper2 = UITapGestureRecognizer(target: self, action: #selector(viewFriends))
        activitiesTab.addGestureRecognizer(tapper1)
        friendsTab.addGestureRecognizer(tapper2)
        
        tabs.axis = .horizontal
        tabs.distribution = .fillEqually
        
        header.eqBottom(tabs)
        activitiesVC.user = user
        activitiesVC.delegate = self
        friendsVC.user = user
        friendsVC.delegate = self
        
        viewControllers = [activitiesVC, friendsVC]
        
        if user == nil {
            UserManager.shared.getCurrentUser(onSuccess: { currentUser in
                self.user = currentUser
                self.activitiesVC.user = currentUser
                self.friendsVC.user = currentUser
                
                editButton.isHidden = false
            }, onError: { error in
                alert()
            })
        } else {
            loadUser()
        }
        
        setupScrolling()
        
        if shouldShowFriendsFirst {
            viewFriends()
        }
        
        updateViewColors()
    }
    
    @objc func editProfile() {
        let editProfileViewController = EditProfileViewController()
        editProfileViewController.user = user
        self.present(editProfileViewController, animated: true, completion: nil)
    }
    
    func loadUser() {
        user?.registerReceiver(self, onDataUpdate: updateUser(_:_:))
    }
    
    func updateUser(_ sender: NewProfileViewController, _ user: User) {
        if let imageUrl = user.profileimage {
            profileImageView.loadImageFromURL(imageUrl)
        }
        nameLabel.text = user.fullName()
        bioLabel.text = user.bio
    }
    
    func setupPager() {
        pageView.delegate = self
        pageView.dataSource = self
        pageView.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    @objc func viewActivities() {
        pageView.setViewControllers([activitiesVC], direction: .reverse, animated: true, completion: nil)
        activitiesTab.isSelected = true
        friendsTab.isSelected = false
    }
    
    @objc func viewFriends() {
        pageView.setViewControllers([friendsVC], direction: .forward, animated: true, completion: nil)
        friendsTab.isSelected = true
        activitiesTab.isSelected = false
    }


}

extension NewProfileViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currIdx = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let newIdx = currIdx - 1
        guard newIdx >= 0 && viewControllers.count > newIdx else {
            return nil
        }
        
        let beforeVC = viewControllers[newIdx]
        return beforeVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currIdx = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let newIdx = currIdx + 1
        guard newIdx >= 0 && viewControllers.count > newIdx else {
            return nil
        }
        
        let afterVC = viewControllers[newIdx]
        return afterVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let count = pageViewController.viewControllers?.count, count > 0 else {
            return
        }
            
        let currentVC = pageViewController.viewControllers?[0]
        if currentVC == activitiesVC {
            viewActivities()
        } else if currentVC == friendsVC {
            viewFriends()
        }
    }
    
}

extension NewProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate  {
    
    func setupScrolling() {
        activitiesVC.webView.scrollView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetHeight = scrollView.contentOffset.y
        
        if (headerTopConstraint?.constant ?? 0) - offsetHeight > 0 || (abs(headerTopConstraint?.constant ?? 0) > header.bounds.height && offsetHeight > 0){
        } else {
            headerTopConstraint?.constant -= offsetHeight
            scrollView.contentOffset = .zero
        }
    }
}

extension NewProfileViewController: UserActivitiesViewControllerDelegate, FriendsCollectionViewControllerDelegate {
    func activitySelected(_ activity: ActivityResource) {
        let editor = DiaryEditorViewController()
        editor.activity = activity
        self.navigationController?.pushViewController(editor, animated: true)
    }
    
    func userSelected(_ user: UserResource) {
        let profile = NewProfileViewController()
        profile.user = user
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    func manageFriends() {
        let friendsVC = FriendsTableViewController()
        friendsVC.uid = user?.uid
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
}

class TabView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    let underline: UIView = UIView()
    let label: UILabel = UILabel()
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                label.textColor = AppColors.secondary
                underline.isHidden = false
            } else {
                label.textColor = .lightGray
                underline.isHidden = true
            }
        }
    }
    
    var title: String = "Untitled" {
        didSet {
            label.text = title
        }
    }
    
    private func setup() {
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = rgb(240, 240, 240)
        
        self.addSubviews([label, underline])
        
        label.centerY(self).centerX(self)
        underline.eqLeading(self).eqTrailing(self).eqBottom(self).height(2)
        
        underline.backgroundColor = AppColors.secondary
        underline.isHidden = true
    }
}
