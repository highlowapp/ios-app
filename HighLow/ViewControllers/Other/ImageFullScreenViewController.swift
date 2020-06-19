//
//  ImageFullScreenViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 1/24/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ImageFullScreenViewController: UIViewController, UIScrollViewDelegate {
    
    let imageView: HLImageView = HLImageView(frame: .zero)
    let scrollView: UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(scrollView)
        
        
        self.view.backgroundColor = rgb(230, 230, 230)
        
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5.0

        scrollView.eqTop(self.view).eqLeading(self.view).eqTrailing(self.view).eqBottom(self.view)
        imageView.frame = view.frame
        imageView.contentMode = .scaleAspectFit
        
        
    }
    
    func loadImage(url: String) {
        imageView.loadImageFromURL(url)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
