//
//  FriendsCollectionViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 12/4/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class FriendsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: FriendsCollectionViewControllerDelegate?
    
    var user: UserResource? {
        didSet {
            getFriends()
        }
    }
    
    var headers: [Int:String] = [
        0: "Pending Requests",
        1: "Friends"
    ]
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var pendingRequests: [UserResource] = []
    var friends: [UserResource] = []
    
    var sectionTitleMappings: [String: Int] = [
        "friends": 0,
        "pending_requests": -1,
        "manage_friends": -1
    ]
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override func updateViewColors() {
        self.collectionView.backgroundColor = getColor("Gray2Black")
        
        self.collectionView.visibleCells.forEach { cell in
            cell.updateColors()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        self.layout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 20)
        //self.layout.sectionTitleMappings = self.sectionTitleMappings
        self.layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.collectionView.collectionViewLayout = self.layout
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(NewPendingRequestCollectionViewCell.self, forCellWithReuseIdentifier: "PendingRequestCell")
        self.collectionView.register(FriendCollectionViewCell.self, forCellWithReuseIdentifier: "FriendCell")
        self.collectionView.register(ManageFriendsCollectionViewCell.self, forCellWithReuseIdentifier: "ManageFriendsCell")
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "plain")
        self.collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        self.view.addSubview(collectionView)
        collectionView.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        
        updateViewColors()
        
        getFriends()
    }
    
    func getFriends() {
        user?.getFriends(onSuccess: { friendsResponse in
            self.friends = friendsResponse.friends
            self.pendingRequests = friendsResponse.pendingRequests
            
            if friendsResponse.isCurrentUser {
                self.sectionTitleMappings["manage_friends"] = 0
                self.sectionTitleMappings["pending_requests"] = 1
                self.sectionTitleMappings["friends"] = 2
                self.headers[0] = nil
                self.headers[1] = "Pending Requests"
                self.headers[2] = "Friends"
            } else {
                self.sectionTitleMappings["pending_requests"] = -1
                self.sectionTitleMappings["friends"] = 0
                self.sectionTitleMappings["manage_friends"] = -1
                self.headers[-1] = "Pending Requests"
                self.headers[0] = "Friends"
            }
            self.collectionView.reloadData()
        }, onError: { error in
            alert()
        })
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTitleMappings["pending_requests"] == -1 ? 1:3
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == sectionTitleMappings["pending_requests"] {
            return self.pendingRequests.count
        } else if section == sectionTitleMappings["friends"] {
            return self.friends.count
        } else if section == sectionTitleMappings["manage_friends"] {
            return 1
        }
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == sectionTitleMappings["pending_requests"] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PendingRequestCell", for: indexPath) as! NewPendingRequestCollectionViewCell
            cell.awakeFromNib()
            cell.delegate = self
            cell.user = self.pendingRequests[indexPath.row]
            return cell
        } else if indexPath.section == sectionTitleMappings["friends"] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCollectionViewCell
            cell.awakeFromNib()
            cell.user = self.friends[indexPath.row]
            return cell
        } else if indexPath.section == sectionTitleMappings["manage_friends"] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ManageFriendsCell", for: indexPath) as! ManageFriendsCollectionViewCell
            cell.awakeFromNib()
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plain", for: indexPath      )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SectionHeaderView
            header.text = self.headers[indexPath.section] ?? ""
            
            if indexPath.section == sectionTitleMappings["manage_friends"] || (indexPath.section == sectionTitleMappings["pending_requests"] && self.pendingRequests.count == 0) {
                header.isHidden = true
            } else {
                header.isHidden = false
            }
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == sectionTitleMappings["friends"] {
            let size = CGSize(width: self.view.frame.width/2.1, height: self.view.frame.width/2.1)
            return size
        } else if indexPath.section == sectionTitleMappings["pending_requests"] {
            return CGSize(width: self.view.frame.width, height: 100)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == sectionTitleMappings["friends"] {
            return UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        } else if section == sectionTitleMappings["manage_friends"] {
            return UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == sectionTitleMappings["friends"] {
            let user = self.friends[indexPath.row]
            self.delegate?.userSelected(user)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
    }

}

extension FriendsCollectionViewController: ManageFriendsCollectionViewCellDelegate, NewPendingRequestCollectionViewCellDelegate {
    func wasTapped() {
        self.delegate?.manageFriends()
    }
    
    func decidedPendingRequest() {
        getFriends()
    }
}


class SectionHeaderView: UICollectionReusableView {
    
    let label: UILabel = UILabel()
    
    var text: String = "Untitled" {
        didSet {
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        self.label.font = .systemFont(ofSize: 15, weight: .bold)
        self.label.textColor = rgb(200, 200, 200)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.label.topAnchor.constraint(equalTo: self.topAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    
    
}


class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: LeftAlignedCollectionViewFlowLayoutDelegate?
    
    var sectionTitleMappings: [String: Int] = [
        "pending_requests": -1,
        "friends": 0
    ]
    /*
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach({ layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            }
        })
        return layoutAttributesObjects
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            fatalError()
        }
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        if indexPath.section == sectionTitleMappings["pending_requests"] {
            layoutAttributes.frame.origin.x = sectionInset.left
            layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return super.shouldInvalidateLayout(forBoundsChange: newBounds) }
        let contentOffset = CGSize(width: collectionView.bounds.minX - newBounds.minX, height: collectionView.bounds.minY - newBounds.minY)
        self.delegate?.didScroll(self, contentOffset)
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
 */
}

protocol LeftAlignedCollectionViewFlowLayoutDelegate: AnyObject {
    func didScroll(_ layout: LeftAlignedCollectionViewFlowLayout, _ contentOffset: CGSize)
}


protocol FriendsCollectionViewControllerDelegate: AnyObject {
    func userSelected(_ user: UserResource)
    func manageFriends()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}
