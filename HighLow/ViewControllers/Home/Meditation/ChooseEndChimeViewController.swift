//
//  ChooseBibleVerseViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/1/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ChooseEndChimeViewController: UIViewController {
    let endChimeChooser: UIPickerView = UIPickerView()
    var currentChime: [String: Any] = [
        "title": "Chime 1",
        "value": EndChime.chime1
    ]
    
    let options = [
        [
            "title": "Chime 1",
            "value": EndChime.chime1
        ],
        [
            "title": "Chime 2",
            "value": EndChime.chime2
        ],
        [
            "title": "Chime 3",
            "value": EndChime.chime3
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.addSubviews([endChimeChooser])
        
        let navigationBar = UINavigationBar()
        
        self.view.addSubview(navigationBar)
        
        navigationBar.eqTop(self.view).eqLeading(self.view).eqTrailing(self.view)
        
        let navTitle = UINavigationItem(title: "Choose an End Chime")
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelf))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))
        
        navTitle.leftBarButtonItem = cancel
        navTitle.rightBarButtonItem = done
        
        navigationBar.setItems([navTitle], animated: false)
        navigationBar.tintColor = AppColors.primary
        
        
        endChimeChooser.delegate = self
        endChimeChooser.dataSource = self
        endChimeChooser.backgroundColor = rgb(240, 240, 240)
        
        endChimeChooser.topToBottom(navigationBar).eqLeading(self.view).eqTrailing(self.view)
    }

    @objc func cancelSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButton() {
        let chime: [String: Any] = [
            "chime": currentChime["value"] as! EndChime,
            "title": currentChime["title"] as! String
        ]
        NotificationCenter.default.post(name: .endChimeChanged, object: nil, userInfo: chime)
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChooseEndChimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]["title"] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentChime = options[row]
    }
}
