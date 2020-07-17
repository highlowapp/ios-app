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
        AuthService.shared.currentUser.getDiaryEntries(page: page, onSuccess: { diaryEntries in
            self.refreshControl.endRefreshing()
            if reset {
                self.diaryEntries = []
            }
            self.diaryEntries.append(contentsOf: diaryEntries)
            self.collectionView.reloadData()
        }, onError: { error in
            self.refreshControl.endRefreshing()
            print(error)
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
    }
    
    @objc func update() {
        collectionView.reloadData()
    }
    
    func newDiaryEntry() {
        
    }
    
    func newHighLow() {
        
    }
}
