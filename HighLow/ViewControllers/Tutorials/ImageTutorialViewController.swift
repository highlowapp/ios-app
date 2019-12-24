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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageView)
        
        imageView.eqTop(self.view.safeAreaLayoutGuide).eqWidth(self.view).eqHeight(self.view, 0.0, 0.6)
        
        self.view.addSubview(label)
        
        label.topToBottom(imageView, 10).centerX(self.view).eqWidth(self.view)
        
        label.text = "Image Slide"
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 25)
         
    }
    
    public func withImage(named img: String) -> ImageTutorialViewController {
        imageView.image = UIImage(named: img)
        return self
    }
    
    public func with(title: String, image: String) -> ImageTutorialViewController {
        imageView.image = UIImage(named: image)
        label.text = title
        return self
    }

}
