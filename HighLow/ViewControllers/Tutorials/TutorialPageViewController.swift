//
//  TutorialPageViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/16/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    
    let tutorialViews: [ImageTutorialView] = [
        ImageTutorialView().with(title: "Reflect every day by entering a High/Low", image: "TutorialImg3"),
        ImageTutorialView().with(title: "Connect with Friends based on your Interests", image: "Connect2"),
        ImageTutorialView().with(title: "View their High/Lows in your feed", image: "TutorialImg2", button: true)
    ]
    
    func addTutorialViewControllers(_ tutorialViews: [ImageTutorialView]) {
        scrollView.contentSize = CGSize(width: CGFloat(tutorialViews.count) * view.frame.width, height: view.frame.height)
        
        var prev: UIView? = nil
                
        for i in 0..<tutorialViews.count {
            scrollView.addSubview(tutorialViews[i])
            tutorialViews[i].centerY(view).eqWidth(view)
            
            if prev == nil {
                tutorialViews[i].eqLeading(scrollView)
            } else {
                tutorialViews[i].leadingToTrailing(prev!)
            }
            
            prev = tutorialViews[i]
        }
        
        pageControl.numberOfPages = tutorialViews.count
        pageControl.currentPage = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let pageControl = UIPageControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let skip = UIButton()
        skip.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(skip)
        skip.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        skip.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        skip.widthAnchor.constraint(equalToConstant: 70).isActive = true
        skip.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        skip.setTitle("SKIP", for: .normal)
        skip.setTitleColor(.black, for: .normal)
        
        skip.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
        
        
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(hexString: "#55FB2A57")
        UIPageControl.appearance().currentPageIndicatorTintColor = AppColors.primary
        
        self.view.addSubview(scrollView)
        
        scrollView.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        
        scrollView.isPagingEnabled = true
        
        scrollView.delegate = self
        
        self.view.addSubview(pageControl)
        
        addTutorialViewControllers(tutorialViews)
        
        
        pageControl.centerX(self.view).eqBottom(self.view, -25)
        
        view.bringSubviewToFront(skip)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
                
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
//        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
    
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.50) {
            
            tutorialViews[0].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.50, y: (0.50-percentOffset.x)/0.50)
            tutorialViews[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 1) {
            tutorialViews[1].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.50, y: (1-percentOffset.x)/0.50)
            tutorialViews[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/1, y: percentOffset.x/1)
            
        }
        
    }
    
    @objc func skipTutorial() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasReceivedTutorial")
        switchToAuth()
    }
    

}

