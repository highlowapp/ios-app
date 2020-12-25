//
//  NewDiaryViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class NewDiaryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DiaryCollectionViewCellDelegate {
    
    //This is just for the pull-to-refresh
    private let refreshControl = UIRefreshControl()
    
    //One of the diary items was deleted
    func didDelete(sender: DiaryCollectionViewCell) {
        
        //Get its "indexPath" (aka position)
        let indexPath = collectionView.indexPath(for: sender)
        
        //Remove it from the data array
        diaryEntries.remove(at: indexPath!.row)
        
        //Remove it from the collectionview
        collectionView.deleteItems(at: [indexPath!])
    }
    
    //If they decided to edit the sharing permissions on the diary entry
    func editPermissions(sender: DiaryCollectionViewCell) {
        
        //Create a sharingPolicyViewController
        let sharingPolicyViewController = SharingPolicyViewController()
        
        //Set the activity
        sharingPolicyViewController.activity = sender.activity
        
        //Present the new view controller
        self.present(sharingPolicyViewController, animated: true)
    }
    
    //This keeps track of all the diary entries
    var diaryEntries: [ActivityResource] = []
    
    //This tells us what page of diary entries we're fetching
    var page = 0
    
    //This just updates colors in the view for dark mode
    override func updateViewColors() {
        self.view.backgroundColor = getColor("White2Black")
        self.collectionView.backgroundColor = getColor("White2Black")
        
        collectionView.visibleCells.forEach { cell in
            cell.updateColors()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewColors()
    }
    
    //When the view first loads
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        //Set the refreshControl (for pull to refresh)
        collectionView.refreshControl = refreshControl
        
        //Set the refreshControl target (again, for pull to refresh)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        //Register the DiaryCollectionViewCell type
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryItem")
        collectionView.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: "Message")
        
        //Set the layout
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        
        //Get the diary entries
        getDiaryEntries()
        
        //Observe the "updatedDiary" notification
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: "updatedDiary"), object: nil)
        
        //Update the view colors
        updateViewColors()
    }
    
    //To reload the diary entries
    @objc func refresh() {
        getDiaryEntries()
    }
    
    //To get the diary entries
    func getDiaryEntries(page: Int = 0) {
        self.page = page
        
        //First we get the current user
        UserManager.shared.getCurrentUser(onSuccess: { currentUser in
            
            //Then we get the user's diary entries using the page number
            currentUser.getDiaryEntries(page: page, onSuccess: { diaryEntries in
                
                //After we're done loading, we stop the loading indicator
                self.refreshControl.endRefreshing()
                
                //If we were told to reset, we empty the diaryEntries array
                if page == 0 {
                    self.diaryEntries = []
                }
                
                //We add all the new diary entries to our array
                self.diaryEntries.append(contentsOf: diaryEntries)
                
                //We have the collectionView reload its data
                self.collectionView.reloadData()
                
            }, onError: { error in
                
                //If there was an error, we alert the user and stop the loading indicator
                alert()
                self.refreshControl.endRefreshing()
            })
        }, onError: { error in
            
            alert()
            self.refreshControl.endRefreshing()
        })
    }
    
    //The number of items in the section will be the same as the number of diary entries
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(diaryEntries.count, 1)
    }
    
    //To get the cell for a specific indexPath (aka position)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if diaryEntries.count == 0 && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Message", for: indexPath) as! MessageCollectionViewCell
            cell.awakeFromNib()
            cell.message = "Your diary entries will appear here"
            
            return cell
        }
        
        //Create a DiaryCollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryItem", for: indexPath) as! DiaryCollectionViewCell
        
        //Run its setup
        cell.awakeFromNib()
        
        //Configure it with its indexPath and an activity from the diaryEntries
        cell.configure(indexPath: indexPath, activity: diaryEntries[indexPath.row])
        
        //Set its delegate to ourselves
        cell.delegate = self
        
        //Return the cell
        return cell
    }
    
    //To get the size for each cell
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize {
        
        if diaryEntries.count == 0 && sizeForItemAt.row == 0 {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        
        //It's about half the width of the view so we have two columns
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2.5)
        
    }
    
    //We only have one section
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Setting the insets for the section
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAt: Int) -> UIEdgeInsets {
        
        //This is just 20 pixels of padding all the way around
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
    }
    
    //If an item was selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Get the activity for that item
        let activity = diaryEntries[indexPath.row]
        
        //If it was a diary or a highlow...
        if activity.type == "diary" || activity.type == "highlow" {
            
            //Create a view controller with the Reflect editor
            let editor = DiaryEditorViewController()
            
            //Set the activity
            editor.activity = activity
            
            //Add the view controller to our navigation stack
            self.navigationController?.pushViewController(editor, animated: true)
            
        }
        
        //If the activity was an audio entry...
        else if activity.type == "audio" {
            
            //Create an audio editor view controller
            let editor = RecordAudioDiaryViewController()
            
            //Set the activity
            editor.activity = activity
            
            //Present the audio editor
            self.present(editor, animated: true)
            
        }
    }
    
    //Just some spacing between elements
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    //If a cell is about to be displayed
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //If the cell is near the bottom
        if indexPath.row >= (page + 1) * 10 - 1 {
            
            //Increment the page number
            page += 1
            
            //Get the diary entries at the new page
            getDiaryEntries(page: page)
            
        }
        
    }
    
    //This is for the context menu (only for iOS)
    @available(iOS 13.0, *)
    override func collectionView (_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration {
        
        //Create a context menu configuration
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
            
            //Create an item for deleting entries
            let deleteItem = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: UIAction.Identifier(rawValue: "delete"), attributes: [.destructive]) { _ in
                
                //Get the specified item
                let cell = collectionView.cellForItem(at: indexPath) as! DiaryCollectionViewCell
                
                //Delete the activity
                cell.activity?.delete(onSuccess: { activity in
                    self.didDelete(sender: cell)
                }, onError: { error in
                    alert("An error occurred", "Please try again")
                })
            }
            
            //Create an item for managing the sharing policy
            let sharingPolicyItem = UIAction(title: "Edit Permissions", image: UIImage(systemName: "compose"), identifier: UIAction.Identifier(rawValue: "compose")) { _ in
                
                //Get the specified item
                let cell = collectionView.cellForItem(at: indexPath) as! DiaryCollectionViewCell
                
                //Get the activity
                let activity = cell.activity
                
                //Create a sharing policy view controller
                let sharingPolicyViewController = SharingPolicyViewController()
                
                //Set the activity
                sharingPolicyViewController.activity = activity
                
                //Present the view controller
                self.present(sharingPolicyViewController, animated: true)
                
            }
            
            
            //Return a UIMenu with the options
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [sharingPolicyItem, deleteItem])
        }
        
        //Return the configuration
        return configuration
        
    }
    
    //This basically just reloads data
    @objc func update() {
        collectionView.reloadData()
    }
    
    
    //These are useless now
    func newDiaryEntry() {
        
    }
    
    func newHighLow() {
        
    }
}
