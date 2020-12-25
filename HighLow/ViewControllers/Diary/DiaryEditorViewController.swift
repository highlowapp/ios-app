//
//  DiaryEditorViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/9/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import EasyTipView
import Foundation

class DiaryEditorViewController: ReflectEditorViewController {
    
    var activity: ActivityResource?
    let ai: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    let saving: UILabel = UILabel()
    var shareButton: UIBarButtonItem?
    
    override var type: String {
        get {
            return activity!.type!
        }
        set {
            
        }
    }
    
    override func updateViewColors() {
        themeSwitch(onDark: {
            self.darkMode()
        }, onLight: {
            self.lightMode()
        }, onAuto: {
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.darkMode()
                } else {
                    self.lightMode()
                }
            } else {
                self.lightMode()
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        title = "Editing"
    }
    
    override func configureEditor() {
        super.configureEditor()
        updateViewColors()
        
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
        
        let container = Pill()
        container.clipsToBounds = true
        container.backgroundColor = AppColors.secondary
        
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(editSharingPolicy))
        container.addGestureRecognizer(tapper)
        
        let label = UILabel()
        label.textColor = .white
        label.text = "Share"
        label.textAlignment = .center
        
        container.addSubview(label)
        label.eqTop(container, 5).centerX(container)
        container.eqLeading(label, -10).eqTrailing(label, 10).eqBottom(label, 5)
        
        shareButton = UIBarButtonItem(customView: container)
        
        navigationItem.rightBarButtonItem = shareButton
        
        
        if let blocks = activity?.data?.value(forKey: "blocks") as? [NSDictionary] {
            setBlocks(blocks)
        }
    }
    
    
    func showHelper() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColor = AppColors.primary
        preferences.drawing.arrowPosition = .top
        
        EasyTipView.show(animated: true, forItem: shareButton!, withinSuperview: nil, text: "When you're done editing, you can share your post with others here. Until then, only you can see it.", preferences: preferences, delegate: nil)
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasSeenTooltip.sharing")
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
            
            if !UserDefaults.standard.bool(forKey: "com.gethighlow.hasSeenTooltip.sharing") {
                self.showHelper()
            }
        }, onError: { error in
            self.saving.textColor = .red
            self.saving.text = "Error When Saving"
        })
    }

    override func hasEdited() {
        
    }
    
    @objc func editSharingPolicy() {
        let sharingPolicyViewController = SharingPolicyViewController()
        sharingPolicyViewController.activity = activity
        self.present(sharingPolicyViewController, animated: true)
    }
}
