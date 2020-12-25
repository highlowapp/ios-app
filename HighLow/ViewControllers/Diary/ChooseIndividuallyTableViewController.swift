//
//  ChooseIndividuallyTableViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/29/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import Purchases

struct ChooseIndividuallyItem {
    let user: UserResource
    var isActivated: Bool
}

class ChooseIndividuallyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChooseIndividuallyTableViewCellDelegate {
    
    func toggle(state: Bool, uid: String?) {
        if let theUid = uid {
            for i in 0..<items.count {
                if items[i].user.uid == theUid {
                    items[i].isActivated = state
                }
            }
        }
    }
    
    var policy: NSDictionary?
    var activity: ActivityResource?
    
    var items: [ChooseIndividuallyItem] = []
    
    let tableView: UITableView = UITableView()
    let saveButton: HLButton = HLButton(frame: .zero)
    
    weak var delegate: ChooseIndividuallyTableViewControllerDelegate?
    
    override func updateViewColors() {
        self.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        updateViewColors()
        
        let cancel = cancelButton()
        let separator = UIView()
        
        separator.backgroundColor = rgb(240, 240, 240)
        
        saveButton.colorStyle = "pink"
        saveButton.title = "Save"
        saveButton.backgroundColor = AppColors.primary
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        self.addSubviews([cancel, tableView, separator, saveButton])
        
        setConstraints(cancel: cancel, tableView: tableView, separator: separator, saveButton: saveButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChooseIndividuallyTableViewCell.self, forCellReuseIdentifier: "ChooseIndividually")
        
        
        
        loadFriends()
    }
    
    private func cancelButton() -> UIButton {
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(AppColors.primary, for: .normal)
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        return cancel
    }
    
    private func setConstraints(cancel: UIButton, tableView: UITableView, separator: UIView, saveButton: HLButton) {
        cancel.eqTrailing(self.view, -10).eqTop(self.view, 10)
        tableView.topToBottom(cancel, 10).eqLeading(self.view).eqTrailing(self.view).bottomToTop(separator)
        saveButton.eqBottom(self.view, -20).eqLeading(self.view, 20).eqTrailing(self.view, -20).height(50)
        separator.bottomToTop(saveButton, -20).eqLeading(self.view).eqTrailing(self.view).height(1)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if error != nil {
                alert("An error occurred", "Please try again")
            }
            
            if purchaserInfo?.entitlements["Premium"]?.isActive == true {
                self.saveButton.startLoading()
                self.activity?.setSharingPolicy(category: "uids", uids: self.uidsList(), onSuccess: {
                    self.saveButton.stopLoading()
                    self.dismiss(animated: true, completion: {
                        self.delegate?.didSave()
                    })
                }, onError: { error in
                    self.saveButton.stopLoading()
                    alert("An error occurred", "Please try again")
                })
            } else {
                let paywall = getPaywall()
                self.present(paywall, animated: true)
            }
        }
    }
    
    private func loadFriends() {
        UserManager.shared.getCurrentUser(onSuccess: { currentUser in
            currentUser.getFriends(onSuccess: { friendsResponse in
                let uids = self.policy?["uids"] as? [String]
                self.items = []
                for friend in friendsResponse.friends {
                    if uids != nil {
                        self.items.append(ChooseIndividuallyItem(user: friend, isActivated: uids!.contains(friend.uid!)))
                    } else {
                        self.items.append(ChooseIndividuallyItem(user: friend, isActivated: false))
                    }
                }
                self.tableView.reloadData()
            }, onError: { error in
                alert("An error occurred", "Please try again")
            })
        }, onError: { error in
            alert("An error occurred", "Please try again")
        })
    }
    
    private func uidsList() -> [String] {
        var uids: [String] = []
        for item in items {
            if item.isActivated {
                if let uid = item.user.uid {
                    uids.append(uid)
                }
            }
        }
        return uids
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseIndividually", for: indexPath) as! ChooseIndividuallyTableViewCell
        cell.awakeFromNib()
        cell.loadItem(items[indexPath.row])
        cell.delegate = self
        return cell
    }
}

protocol ChooseIndividuallyTableViewControllerDelegate: AnyObject {
    func didSave()
}

class ChooseIndividuallyTableViewCell: UITableViewCell {
    weak var delegate: ChooseIndividuallyTableViewCellDelegate?
    
    var item: ChooseIndividuallyItem?
    
    let img: HLImageView = HLImageView(frame: .zero)
    let name: UILabel = UILabel()
    let toggle: UISwitch = UISwitch()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img.layer.cornerRadius = 15
        
        name.font = .preferredFont(forTextStyle: .body)
        
        toggle.onTintColor = AppColors.primary
        toggle.addTarget(self, action: #selector(didToggle), for: .valueChanged)
        
        self.contentView.addSubview(img)
        self.contentView.addSubview(name)
        self.contentView.addSubview(toggle)
        
        img.eqLeading(self.contentView, 10).width(30).aspectRatioFromWidth(1).centerY(self.contentView)
        name.leadingToTrailing(img, 5).centerY(img).trailingToLeading(toggle, -5)
        toggle.eqTrailing(self.contentView, -10).centerY(img)
    }
    
    func loadItem(_ item: ChooseIndividuallyItem) {
        self.item = item
        item.user.registerReceiver(self, onDataUpdate: updateUser(_:_:))
        self.toggle.isOn = item.isActivated
        delegate?.toggle(state: self.toggle.isOn, uid: item.user.uid)
    }
    
    func updateUser(_ owner: ChooseIndividuallyTableViewCell, _ user: User) {
        if let url = user.profileimage {
            self.img.loadImageFromURL(url)
        }
        
        self.name.text = user.fullName()
    }
    
    @objc func didToggle() {
        guard let uid = self.item?.user.uid else {
            return
        }
        self.item?.isActivated = self.toggle.isOn
        delegate?.toggle(state: self.toggle.isOn, uid: uid)
    }
}

protocol ChooseIndividuallyTableViewCellDelegate: AnyObject {
    func toggle(state: Bool, uid: String?)
}
