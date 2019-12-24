//
//  TutorialViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/15/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftGifOrigin

@IBDesignable
class GifTutorialViewController: UIViewController {
    let imageView: UIImageView = UIImageView()
    let label: UILabel = UILabel()
    let containerView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .none
        
        let cleanArea = UIView()
        cleanArea.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cleanArea)
        
        cleanArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        cleanArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        cleanArea.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        
        cleanArea.backgroundColor = rgb(250,250,250)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowOpacity = 1
        containerView.clipsToBounds = false
        
        
        containerView.addSubview(imageView)
        containerView.layer.cornerRadius = 7
        imageView.layer.cornerRadius = 7
        
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        imageView.clipsToBounds = true
        
        cleanArea.addSubview(containerView)
        
        containerView.centerXAnchor.constraint(equalTo: cleanArea.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: cleanArea.topAnchor, constant: 20).isActive = true
        containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.556).isActive = true
        containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        
        cleanArea.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20).isActive = true
        
        
        
        
        label.font = .systemFont(ofSize: 25)
        label.text = "Swipe to see previous High/Lows"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        label.topAnchor.constraint(equalTo: cleanArea.bottomAnchor, constant: 10).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        
    }
    
    func loadGif(named gif: String) -> GifTutorialViewController {
        imageView.loadGif(name: gif)
        return self
    }
    
    func loadData(title: String, img: UIImage) -> GifTutorialViewController {
        label.text = title
        imageView.image = img
        return self
    }
    
}
