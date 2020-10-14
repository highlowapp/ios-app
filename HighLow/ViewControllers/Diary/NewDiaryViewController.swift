//
//  NewDiaryViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class NewDiaryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DiaryCollectionViewCellDelegate {
    private let refreshControl = UIRefreshControl()
        
    func didDelete(sender: DiaryCollectionViewCell) {
        let indexPath = collectionView.indexPath(for: sender)
        
        diaryEntries.remove(at: indexPath!.row)
        collectionView.deleteItems(at: [indexPath!])
    }
    
    func editPermissions(sender: DiaryCollectionViewCell) {
        let sharingPolicyViewController = SharingPolicyViewController()
        sharingPolicyViewController.activity = sender.activity
        self.present(sharingPolicyViewController, animated: true)
    }
    
    
    var diaryEntries: [ActivityResource] = []
    var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryItem")
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        getDiaryEntries(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: "updatedDiary"), object: nil)
    }
    
    @objc func refresh() {
        getDiaryEntries(true)
    }
    
    func getDiaryEntries(_ reset: Bool = false) {
        UserManager.shared.getCurrentUser(onSuccess: { currentUser in
            currentUser.getDiaryEntries(page: self.page, onSuccess: { diaryEntries in
                self.refreshControl.endRefreshing()
                if reset {
                    self.diaryEntries = []
                }
                self.diaryEntries.append(contentsOf: diaryEntries)
                self.collectionView.reloadData()
            }, onError: { error in
                self.refreshControl.endRefreshing()
            })
        }, onError: { error in
            self.refreshControl.endRefreshing()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryEntries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryItem", for: indexPath) as! DiaryCollectionViewCell
        cell.awakeFromNib()
        cell.configure(indexPath: indexPath, activity: diaryEntries[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2.5)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activity = diaryEntries[indexPath.row]
        
        if activity.type == "diary" || activity.type == "highlow" {
            let editor = DiaryEditorViewController()
            editor.activity = activity
            self.navigationController?.pushViewController(editor, animated: true)
        }
        
        else if activity.type == "audio" {
            let editor = RecordAudioDiaryViewController()
            editor.activity = activity
            self.present(editor, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    @available(iOS 13.0, *)
    override func collectionView (_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
            let deleteItem = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: UIAction.Identifier(rawValue: "delete"), attributes: [.destructive]) { _ in
                let cell = collectionView.cellForItem(at: indexPath) as! DiaryCollectionViewCell
                cell.activity?.delete(onSuccess: { activity in
                    self.didDelete(sender: cell)
                }, onError: { error in
                    alert("An error occurred", "Please try again")
                })
            }
            
            let sharingPolicyItem = UIAction(title: "Edit Permissions", image: UIImage(systemName: "compose"), identifier: UIAction.Identifier(rawValue: "compose")) { _ in
                let cell = collectionView.cellForItem(at: indexPath) as! DiaryCollectionViewCell
                let activity = cell.activity
                let sharingPolicyViewController = SharingPolicyViewController()
                sharingPolicyViewController.activity = activity
                self.present(sharingPolicyViewController, animated: true)
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [sharingPolicyItem, deleteItem])
        }
        
        return configuration
    }
    
    @objc func update() {
        collectionView.reloadData()
    }
    
    func newDiaryEntry() {
        
    }
    
    func newHighLow() {
        
    }
}
