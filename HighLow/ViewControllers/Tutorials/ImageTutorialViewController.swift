//
//  ImageTutorialViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 12/19/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class ImageTutorialViewController: UIViewController {
    
    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    
    convenience init(title: String) {
        self.init(nibName: nil, bundle: nil)
        
        label.text = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageView)
        
        imageView.eqTop(self.view.safeAreaLayoutGuide, 50).eqWidth(self.view)
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.14).isActive = true
        
        self.view.addSubview(label)
        
        label.topToBottom(imageView, 10).centerX(self.view).eqWidth(self.view, 0.0, 0.9)
        
        label.numberOfLines = 0
        label.textColor = AppColors.primary
        label.font = UIFont(name: "Chalkboard SE", size: 25.0)
        label.textAlignment = .center
         
    }
    
    public func withImage(named img: String) -> ImageTutorialViewController {
        imageView.image = UIImage(named: img)
        return self
    }
    
    public func with(title: String, image: String, button: Bool = false) -> ImageTutorialViewController {
        imageView.image = UIImage(named: image)
        label.text = title
        
        if button {
            let btn = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 45))
            btn.colorStyle = "white"
            btn.title = "Get Started!"
            
            self.view.addSubview(btn)
            
            btn.topToBottom(label, 10).eqWidth(self.view, 0.0, 0.6).height(45).centerX(self.view)
            
            btn.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
        }
        
        return self
    }
    
    @objc func skipTutorial() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasReceivedTutorial")
        switchToAuth()
    }

}
