//
//  ChooseMeditationFocusViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 8/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

struct MeditationFocus {
    var title: String
    var content: String
}

class ChooseMeditationFocusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView = UITableView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar()
        
        self.view.addSubview(navigationBar)
        
        navigationBar.eqTop(self.view).eqLeading(self.view).eqTrailing(self.view)
        
        let navTitle = UINavigationItem(title: "Choose Focus")
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelf))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))
        
        navTitle.leftBarButtonItem = cancel
        navTitle.rightBarButtonItem = done
        
        navigationBar.setItems([navTitle], animated: false)
        navigationBar.tintColor = AppColors.primary

        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        
        tableView.topToBottom(navigationBar).eqLeading(self.view.safeAreaLayoutGuide).eqTrailing(self.view.safeAreaLayoutGuide).eqBottom(self.view.safeAreaLayoutGuide)
        
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "Custom")
        tableView.register(HolyBibleTableViewCell.self, forCellReuseIdentifier: "Scripture")
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Custom"
        } else {
            return "Scripture"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Custom", for: indexPath) as! TextFieldTableViewCell
            cell.awakeFromNib()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Scripture", for: indexPath) as! HolyBibleTableViewCell
            cell.awakeFromNib()
            return cell
        }
    }
    
    @objc func cancelSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let chooseBibleVerseViewController = ChooseBibleVerseViewController()
            self.present(chooseBibleVerseViewController, animated: true)
        }
    }
}

