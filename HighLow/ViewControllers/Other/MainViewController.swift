//
//  MainViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 5/31/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


class MainViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:"com.gethighlow.uidFromNotification"), object: nil, queue: nil, using: openFriendsViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:"com.gethighlow.uidFromNotification"), object: nil, queue: nil, using: openFriendsViewController)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func openFriendsViewController(notification: Notification) {
        NSLog("GOTUIDFROMNOTIFICATION")
        
        let friendsVC = FriendsTableViewController()
        self.present(friendsVC, animated: true, completion: nil)
    }

}
