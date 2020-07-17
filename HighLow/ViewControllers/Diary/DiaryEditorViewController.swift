//
//  DiaryEditorViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/9/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class DiaryEditorViewController: ReflectEditorViewController {
    
    var activity: ActivityResource?
    let ai: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    let saving: UILabel = UILabel()
    
    override var type: String {
        get {
            return activity!.type!
        }
        set {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Editing"
    }
    
    override func configureEditor() {
        super.configureEditor()
        
        let loader = UIStackView()
        loader.axis = .horizontal
        loader.distribution = .equalSpacing
        loader.spacing = 5
        
        ai.hidesWhenStopped = true
        loader.addArrangedSubview(ai)
        
        
        saving.text = "Saved"
        saving.textColor = .gray
        loader.addArrangedSubview(saving)
        
        navigationItem.titleView = loader
        
        
        if let blocks = activity?.data?.value(forKey: "blocks") as? [NSDictionary] {
            setBlocks(blocks)
        }
    }
    
    override func saveDocument(_ blocks: NSDictionary) {
        ai.startAnimating()
        saving.text = "Saving..."
        saving.textColor = .gray

        var data: [String: Any] = [:]
        data["blocks"] = blocks["blocks"]
        
        activity?.update(data: data as NSDictionary, onSuccess: {
            self.ai.stopAnimating()
            self.saving.textColor = .gray
            self.saving.text = "Saved!"
        }, onError: { error in
            print(error)
            self.saving.textColor = .red
            self.saving.text = "Error When Saving"
        })
    }

    override func hasEdited() {
        let container = Pill()
        container.clipsToBounds = true
        container.backgroundColor = .systemGreen
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(editSharingPolicy))
        container.addGestureRecognizer(tapper)
        
        let label = UILabel()
        label.textColor = .white
        label.text = "Publish"
        label.textAlignment = .center
        
        container.addSubview(label)
        label.eqTop(container, 5).centerX(container)
        container.eqLeading(label, -10).eqTrailing(label, 10).eqBottom(label, 5)
        
        let shareButton = UIBarButtonItem(customView: container)
        
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func editSharingPolicy() {
        let sharingPolicyViewController = SharingPolicyViewController()
        sharingPolicyViewController.activity = activity
        self.present(sharingPolicyViewController, animated: true)
    }
}
