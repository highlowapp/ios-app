//
//  HLNavigationController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/14/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HLNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("com.gethighlow.highlowidFromNotification"), object: nil, queue: nil, using: highlowidFromNotification)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    func highlowidFromNotification(notification: Notification) {
        if let highlowid = notification.userInfo?["highlowid"] as? String {
            let homeViewController = HomeViewController()
            homeViewController.highlow.highlowid = highlowid
            
            self.pushViewController(homeViewController, animated: true)
        }
    }

}
