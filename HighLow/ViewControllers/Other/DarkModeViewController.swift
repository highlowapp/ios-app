//
//  DarkModeViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 4/1/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class DarkModeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        let container = UIView()
        self.view.addSubview(container)
        
        container.centerY(self.view).eqWidth(self.view).centerX(self.view)
        
        let header = UILabel()
        header.text = "Dark Mode is here!"
        header.textColor = .black
        header.font = .systemFont(ofSize: 30, weight: .bold)
        header.textAlignment = .center
        header.numberOfLines = 0
        
        container.addSubview(header)
        
        header.eqWidth(container, 0.0, 0.7).centerX(container).eqTop(container)
        
        let darkImg = UIImageView(image: UIImage(named: "DarkModePromo"))
        darkImg.contentMode = .scaleAspectFill
        
        container.addSubview(darkImg)
        
        darkImg.topToBottom(header, 20).centerX(container).eqWidth(self.view, 0, 0.8).aspectRatioFromWidth(0.56)
        
        let subheader = UILabel()
        subheader.textColor = .black
        subheader.font = .systemFont(ofSize: 20)
        subheader.textAlignment = .center
        subheader.numberOfLines = 0
        
        subheader.text = "You'll find the theme controls in the About tab under the 'Settings' section!"
        
        container.addSubview(subheader)
        
        subheader.eqWidth(darkImg).topToBottom(darkImg, 20).centerX(container)
        
        let button = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        button.title = "Dismiss"
        button.colorStyle = "pink"
        
        container.addSubview(button)
        
        button.eqWidth(darkImg).topToBottom(subheader, 20).centerX(container).height(40)
        
        button.addTarget(self, action: #selector(dismissClicked), for: .touchUpInside)
        
        container.eqBottom(button)
        
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasSeenDarkMode")
        
    }
    
    
    @objc func dismissClicked() {
        self.dismiss(animated: true, completion: nil)
    }

}
