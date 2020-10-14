//
//  SharingPolicyViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/16/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class SharingPolicyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChooseIndividuallyTableViewControllerDelegate {
    
    let options: [SharingPolicyOption] = [
        SharingPolicyOption(image: UIImage(named: "Lock")!, title: "Private", policyDescription: "Only you can see your entry", categoryTitle: "none"),
        SharingPolicyOption(image: UIImage(named: "Globe")!, title: "Public", policyDescription: "Anyone can view your entry", categoryTitle: "all"),
        SharingPolicyOption(image: UIImage(named: "FriendsGroup")!, title: "Friends", policyDescription: "You and your friends can see your entry", categoryTitle: "friends"),
        SharingPolicyOption(image: UIImage(named: "SupportGroup")!, title: "Support Group", policyDescription: "Members of your Support Group can see your entry", categoryTitle: "supportGroup"),
        SharingPolicyOption(image: UIImage(named: "ChooseIndividually")!, title: "Choose", policyDescription: "The people you choose can see your entry", categoryTitle: "uids")
    ]
    
    var sharingPolicy: NSDictionary?
    
    var activity: ActivityResource?
    
    let sharingTypes: [String: Int] = [
        "none": 0,
        "all": 1,
        "friends": 2,
        "supportGroup": 3,
        "uids": 4
    ]
    
    var uids: [String]?
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let descriptor: UILabel = UILabel()
    let save: HLButton = HLButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(AppColors.primary, for: .normal)
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let title = UILabel()
        title.text = "Who sees your content?"
        title.font = .preferredFont(forTextStyle: .title1)
        title.textAlignment = .center
        title.numberOfLines = 0
        
        
        let separator = UIView()
        separator.backgroundColor = rgb(240, 240, 240)
        
        let saveArea = UIView()
        saveArea.backgroundColor = .white
        /*
        saveArea.layer.shadowRadius = 5
        saveArea.layer.shadowColor = UIColor.black.cgColor
        saveArea.layer.shadowOpacity = 0.1
        */
        
        descriptor.textColor = AppColors.primary
        descriptor.numberOfLines = 0
        descriptor.font = .preferredFont(forTextStyle: .callout)
        descriptor.textAlignment = .center
        
        
        save.colorStyle = "pink"
        save.title = "Save"
        
        save.addTarget(self, action: #selector(saveChoice), for: .touchUpInside)
        
        save.backgroundColor = AppColors.primary
        
        let saveLabel = UILabel()
        saveLabel.text = "Save"
        saveLabel.textColor = .white
        saveLabel.textAlignment = .center
        
        //save.addSubview(saveLabel)
        //saveLabel.centerX(save).centerY(save)
        
        view.addSubview(cancel)
        cancel.eqTop(view, 10).eqTrailing(view, -20)
        
        view.addSubview(title)
        title.topToBottom(cancel, 20).eqWidth(view, 0, 0.8).centerX(view)

        view.addSubview(collectionView)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SharingPolicyCollectionViewCell.self, forCellWithReuseIdentifier: "option")
        
        collectionView.backgroundColor = .white
        
        view.addSubview(separator)
        view.addSubview(saveArea)
        saveArea.addSubview(descriptor)
        saveArea.addSubview(save)
        
        save.eqLeading(saveArea, 20).eqTrailing(saveArea, -20).eqBottom(saveArea, -20).height(50)
        descriptor.bottomToTop(save, -15).eqLeading(saveArea, 20).eqTrailing(saveArea, -20)
        saveArea.eqLeading(view).eqTrailing(view).eqBottom(view).eqTop(descriptor, -15)
        separator.bottomToTop(saveArea).eqLeading(view).eqTrailing(view).height(1)
        
        
        collectionView.topToBottom(title, 10).bottomToTop(separator).eqLeading(view).eqTrailing(view)
        
        activity?.getSharingPolicy(onSuccess: { sharingPolicy in
            guard let sharedWith = sharingPolicy["sharing_policy"] as? String else {
                return
            }
            
            self.sharingPolicy = sharingPolicy
            
            let sharedWithKeyword = sharedWith
            
            
            guard let num = self.sharingTypes[sharedWithKeyword] else {
                return
            }
                        
            let indexPath = IndexPath(row: num, section: 0)
            
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            let cell = self.collectionView.cellForItem(at: indexPath) as! SharingPolicyCollectionViewCell
            cell.wasSelected()
            self.descriptor.text = self.options[num].policyDescription
            
        }, onError: { error in
            
        })
    }
    
    @objc func saveChoice() {
        
        
        save.startLoading()
        guard let selected = collectionView.indexPathsForSelectedItems?[0] else {
            return
        }
        
        let sharingOption = options[selected.row]
        
        if sharingOption.categoryTitle == "uids" {
            save.stopLoading()
            let paywall = getPaywall()
            self.present(paywall, animated: true)
            return
        }
        
        activity?.setSharingPolicy(category: sharingOption.categoryTitle, uids: self.uids, onSuccess: {
            self.save.stopLoading()
            self.dismiss(animated: true, completion: nil)
        }, onError: { error in
            self.save.stopLoading()
            alert("An error occurred", "Please try again")
        })
            
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSave() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CollectionView Delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option", for: indexPath) as! SharingPolicyCollectionViewCell
        cell.awakeFromNib()
        cell.loadSharingPolicyOption( options[indexPath.row] )
        if cell.isSelected {
            cell.wasSelected()
        } else {
            cell.wasDeselected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 40)/2.4, height: (collectionView.frame.height/3.1 ))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.frame.height/12*0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SharingPolicyCollectionViewCell else {
            return
        }
        cell.wasSelected()
        let option = self.options[indexPath.row]
        self.descriptor.text = option.policyDescription
        
        if option.categoryTitle == "uids" {
            let chooseIndividuallyTableViewController = ChooseIndividuallyTableViewController()
            chooseIndividuallyTableViewController.policy = sharingPolicy
            chooseIndividuallyTableViewController.activity = self.activity
            chooseIndividuallyTableViewController.delegate = self
            self.present(chooseIndividuallyTableViewController, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SharingPolicyCollectionViewCell else {
            return
        }
        cell.wasDeselected()
        self.descriptor.text = self.options[indexPath.row].policyDescription
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 5, right: 20)
    }
    
}
