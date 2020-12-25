//
//  UpdatingNavigationViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 12/14/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class UpdatingNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChange), name: Notification.Name("com.gethighlow.themeChanged"), object: nil)
    }
    
   

}
