//
//  CustomTabBarController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTabBarController: UITabBarController, AddingOptionsViewControllerDelegate {
    func didSelectItem() {
        self.onAddButtonTap()
    }
    

    let addButton: UIView = UIView()
    var popup: Bool = false
    let addingOptionsViewController = AddingOptionsViewController()
    
    override func updateViewColors() {
        guard let tabBar = tabBar as? CustomTabBar else { return }
        tabBar.barColor = getColor("TabBar")
    }
    
    @objc func gotUserUid(notification: Notification) {
        self.selectedIndex = 1
        guard let profileViewController = self.viewControllers?[1] as? NewProfileViewController else { return }
        profileViewController.shouldShowFriendsFirst = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        NotificationCenter.default.addObserver(self, selector: #selector(gotUserUid(notification:)), name: NSNotification.Name("com.gethighlow.uidFromNotification"), object: nil)
        
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -10)
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowRadius = 10
        
        view.addSubview(addButton)
        
        addButton.backgroundColor = AppColors.primary
        addButton.centerX(view)
        addButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        addButton.width(70).aspectRatioFromWidth(1)
        addButton.layer.cornerRadius = 35
        
        let plusIcon = UIImageView(image: UIImage(named: "Plus"))
        addButton.addSubview(plusIcon)
        
        plusIcon.centerX(addButton).centerY(addButton).width(35).aspectRatioFromWidth(1)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(onAddButtonTap))
        addButton.addGestureRecognizer(tapper)
 
        
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.1
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        addingOptionsViewController.delegate = self
    }
    
    @objc func onAddButtonTap() {
        popup = !popup
        
        if popup {
            self.addChild(addingOptionsViewController)
            addingOptionsViewController.didMove(toParent: self)
            self.view.addSubview(addingOptionsViewController.view)
            addingOptionsViewController.view.bottomToTop(addButton).eqWidth(self.view, 0, 0.9).eqHeight(self.view, 0, 0.5).centerX(self.view)
            addingOptionsViewController.view.layer.opacity = 0
            UIView.animate(withDuration: 0.2) {[weak self] in
                self?.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
                self?.addingOptionsViewController.view.layer.opacity = 1
            }
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                self?.addButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                self?.addingOptionsViewController.view.layer.opacity = 0
            }, completion: {completed in
                self.addingOptionsViewController.willMove(toParent: nil)
                self.addingOptionsViewController.view.removeFromSuperview()
                self.addingOptionsViewController.removeFromParent()
            })
            
            
        }
    }
}
