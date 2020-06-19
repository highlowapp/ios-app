//
//  EditInterestsViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 12/20/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import TagListView

class EditInterestsViewController: UITableViewController, UISearchBarDelegate, InterestTableViewCellDelegate, TagListViewDelegate {
    
    let searchBar: UISearchBar = UISearchBar()
    let tagList: TagListView = TagListView()
    
    var allTags: [[String: String]] = []
    var searchTags: [[String: String]] = []
    
    var myTags: Set<String> = Set<String>()
   
    var idMap: [TagView: String] = [:]
    
    weak var delegate: EditInterestViewControllerDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
        self.delegate?.willDisappear?(tagsList: tagList)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.didDisappear?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        self.view.backgroundColor = getColor("White2Black")
        self.title = "Your Interests"

        tableView.tableHeaderView = UIView()
        
        let header = tableView.tableHeaderView!
        header.addSubview(searchBar)
        header.addSubview(tagList)
        
        tableView.keyboardDismissMode = .onDrag
        
        //Left button
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        tagList.delegate = self
        prepTagList()
        
        searchBar.eqTop(header).centerX(header).eqWidth(header)
        
        searchBar.placeholder = "Search New Interests"
        searchBar.delegate = self
        
        tagList.topToBottom(searchBar, 10).centerX(header).eqWidth(header, -20)
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        
        header.addSubview(separator)
        
        separator.topToBottom(tagList, 10).eqWidth(header).centerX(header).height(1)
        
        let c = header.bottomAnchor.constraint(equalTo: separator.bottomAnchor)
        c.priority = .defaultLow
        c.isActive = true
        
        tableView.layoutIfNeeded()
        
        getMyTags()
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: {
            self.delegate?.didDisappear?()
        })
    }
    
    func getMyTags() {
        authenticatedRequest(url: "/user/interests", method: .get, parameters: [:], onFinish: { json in
            
            if let interests = json["interests"] as? [[String: String]] {
                self.tagList.removeAllTags()
                self.myTags.removeAll()
                
                for interest in interests {
                    let newTag = self.tagList.addTag(interest["name"] ?? "")
                    self.myTags.insert(interest["interest_id"] ?? "")
                    self.idMap[newTag] = interest["interest_id"]
                }
                
                self.tableView.layoutIfNeeded()
                
                self.getAllTags()
            }
            
        }, onError: { error in
            alert("An error occurred", "Please try again")
        })
    }
    
    func getAllTags() {
        authenticatedRequest(url: "/user/interests/all", method: .get, parameters: [:], onFinish: { json in
            if let interests = json["interests"] as? [[String: String]] {
                self.allTags = []

                for interest in interests {
                    if !self.myTags.contains(interest["interest_id"] ?? "") {
                        self.allTags.append(interest)
                    }
                }
                
                self.searchTags = self.allTags
                self.tableView.reloadData()
            }
        }, onError: { error in
            alert("An error occurred", "Please try again")
        })
    }
    
    func prepTagList() {
        tagList.textColor = .white
        tagList.tagBackgroundColor = AppColors.primary
        tagList.cornerRadius = 17
        tagList.textFont = .systemFont(ofSize: 15)
        tagList.paddingX = 10
        tagList.paddingY = 10
        tagList.enableRemoveButton = true
        tagList.removeIconLineColor = .white
    }
 
    func willAdd(id: String, name: String) {
        if id == "" {
            authenticatedRequest(url: "/user/interests/create", method: .post, parameters: ["name": name], onFinish: { json in
                let tagView = self.tagList.addTag(name)
                self.tableView.layoutIfNeeded()
                self.idMap[tagView] = json["interest_id"] as? String ?? ""
                self.myTags.insert(json["interest_id"] as? String ?? "")
                
                self.reloadSearchTags()
            }, onError: { error in
                alert("An error occurred", "Please try again")
            })
            
        } else {
            authenticatedRequest(url: "/user/interests/add", method: .post, parameters: [ "interests": [id] ], onFinish: { json in
                let tagView = self.tagList.addTag(name)
                self.tableView.layoutIfNeeded()
                self.idMap[tagView] = id
                self.myTags.insert(id)
                
                self.reloadSearchTags()
            }, onError: { error in
                alert("An error occurred", "Please try again")
            })
        }
    }
    
    func reloadSearchTags() {
        self.allTags = self.allTags.filter { interest in
            return !self.myTags.contains(interest["interest_id"] ?? "")
        }
        
        self.searchTags = self.allTags
        
        search(searchBar.text ?? "")
    }
    
    func search(_ query: String) {
        searchTags = allTags.filter {
            return $0["name"]!.lowercased().hasPrefix(query.lowercased())
        }
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    func findTagWithName(_ name: String) -> String {
        for tag in allTags {
            if tag["name"]! == name {
                return tag["interest_id"]!
            }
        }
        
        return ""
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if let id = idMap[tagView] {
            sender.removeTagView(tagView)
            tableView.layoutIfNeeded()
            idMap[tagView] = nil
            
            let ids: [String] = [id]
            
            let params: [String: Any] = [
                "interests": ids
            ]
            
            reloadSearchTags()
            
            authenticatedRequest(url: "/user/interests/remove", method: .post, parameters: params, onFinish: { json in
            }, onError: { error in
                alert("An error occurred", "Please try again")
            })
        }
        else {
            alert("An error occurred", "Please try again")
            return
        }
    }
}

extension EditInterestsViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
}

extension EditInterestsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Explore Interests"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTags.count + ((searchBar.text?.count ?? 0 > 0) ? 1:0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InterestTableViewCell(style: .default, reuseIdentifier: "interest")
        
        if  indexPath.row == 0 && searchBar.text?.count ?? 0 > 0 {
            cell.loadInterest([
                "name": searchBar.text ?? ""
            ])
        }
        
        else if searchBar.text?.count ?? 0 > 0 { cell.loadInterest(searchTags[indexPath.row - 1]) }
        else { cell.loadInterest(searchTags[indexPath.row]) }
        cell.delegate = self
        
        return cell
    }
}


class InterestTagView: TagView {
    var id: String?
    
    override init(title: String) {
        super.init(title: title)
    }
    
    init(title: String, id: String) {
        super.init(title: title)
        self.id = id
    }
    
    init(interest: [String: String]) {
        super.init(title: interest["name"] ?? "")
        self.id = interest["interest_id"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


@objc public protocol EditInterestViewControllerDelegate: AnyObject {
    @objc optional func willDisappear(tagsList: TagListView)
    @objc optional func didDisappear()
}
