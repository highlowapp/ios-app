//
//  SharingPolicyViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/16/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class SharingPolicyViewController: UIViewController {
    var activity: ActivityResource?
    
    let sharingTypes: [String: Int] = [
        "none": 0,
        "all": 1,
        "friends": 2,
        "uids": 3
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(AppColors.primary, for: .normal)
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        view.addSubview(cancel)
        cancel.eqTop(view, 10).eqTrailing(view, -20)

        let chooser = UISegmentedControl(items: ["Private", "Public", "Friends", "Choose..."])
        
        activity?.getSharingPolicy(onSuccess: { sharing_policy in
            guard let shared_with = sharing_policy.value(forKey: "sharing_policy") as? [String] else {
                print(sharing_policy.value(forKey: "sharing_policy"))
                return
            }
            if shared_with.count > 0 && self.sharingTypes[ shared_with[0] as! String ] != nil {
                chooser.selectedSegmentIndex = self.sharingTypes[ shared_with[0] as! String ]!
            }
        }, onError: { error in
            
        })
        
        view.addSubview(chooser)
        chooser.topToBottom(cancel, 20).centerX(view)
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
