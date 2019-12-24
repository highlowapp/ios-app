//
//  TutorialPageViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 11/16/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var gradient: CAGradientLayer?
    var angle: CGFloat = -45
    var startColor = AppColors.primary
    var endColor = AppColors.secondary
    
    let tutorialViewControllers: [UIViewController] = [
        GifTutorialViewController().loadGif(named: "HomeScreen"),
        ImageTutorialViewController().with(title: "Connect with Friends based on your Interests", image: "connect_with_friends"),
        ImageTutorialViewController().with(title: "Get a Daily Reminder to Reflect", image: "get_daily_reminder")
    ]
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = tutorialViewControllers.firstIndex(of: viewController)
        
        if index == nil || index! == 0 {
            return nil
        }
        return tutorialViewControllers[index! - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = tutorialViewControllers.firstIndex(of: viewController)
        if index == nil || index! == tutorialViewControllers.count - 1 {
            return nil
        }
        return tutorialViewControllers[index! + 1]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return tutorialViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradient?.frame = self.view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        installGradient()
        updateGradient()
        
        let skip = UIButton()
        skip.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(skip)
        skip.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        skip.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        skip.widthAnchor.constraint(equalToConstant: 70).isActive = true
        skip.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        skip.setTitle("SKIP", for: .normal)
        
        skip.addTarget(self, action: #selector(skipTutorial), for: .touchUpInside)
        
        setViewControllers([tutorialViewControllers.first!], direction: .forward, animated: false, completion: nil)
        
    }
    
    @objc func skipTutorial() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasReceivedTutorial")
        switchToAuth()
    }
    

}

extension TutorialPageViewController {
    
      
      
      
      
      private func installGradient() {

          if let gradient = self.gradient {
              gradient.removeFromSuperlayer()
          }
          
          let gradient = createGradient()
          
          self.view.layer.insertSublayer(gradient, at: 0)
          self.gradient = gradient
      }
      
     
      func updateGradient() {
          
          if let gradient = self.gradient {
              
              let startColor = self.startColor ?? UIColor.clear
              let endColor = self.endColor ?? UIColor.clear
              
              gradient.colors = [startColor.cgColor, endColor.cgColor]
              
              let (start, end) = gradientPointsForAngle(self.angle)
              gradient.startPoint = start
              gradient.endPoint = end
          }
      }
      
     
      private func createGradient() -> CAGradientLayer {
          let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
          return gradient
      }
      
      
      private func gradientPointsForAngle(_ angle: CGFloat) -> (CGPoint, CGPoint) {

          let end = pointForAngle(angle)
     
          let start = oppositePoint(end)
      
          let p0 = transformToGradientSpace(start)
          let p1 = transformToGradientSpace(end)
          
          return (p0, p1)
      }
      
      
      

      private func pointForAngle(_ angle: CGFloat) -> CGPoint {
    
          let radians = angle * .pi / 180.0
          var x = cos(radians)
          var y = sin(radians)

          if (abs(x) > abs(y)) {
         
              x = x > 0 ? 1 : -1
              y = x * tan(radians)
          } else {
             
              y = y > 0 ? 1 : -1
              x = y / tan(radians)
          }
          return CGPoint(x: x, y: y)
      }
      
      
      private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
          return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
      }
      
      private func oppositePoint(_ point: CGPoint) -> CGPoint {
          return CGPoint(x: -point.x, y: -point.y)
      }
      
     
      override func prepareForInterfaceBuilder() {
          super.prepareForInterfaceBuilder()
          installGradient()
          updateGradient()
      }
}
