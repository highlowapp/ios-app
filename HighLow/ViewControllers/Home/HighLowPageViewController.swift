//
//  HighLowPageViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/17/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class HighLowPageViewController: UIPageViewController, CalendarViewControllerDelegate {
    func calendarViewController(willOpenHighLowWithId id: String) {
        let homeViewController = HomeViewController()
        homeViewController.highlow.highlowid = id
        //self.navigationController?.pushViewController(homeViewController, animated: true)
        setViewControllers([homeViewController], direction: .forward, animated: false, completion: nil)
    }
    
    func calendarViewController(willOpenHighLowWithDate date: String) {
        let homeViewController = HomeViewController()
        homeViewController.highlow.date = date
        setViewControllers([homeViewController], direction: .forward, animated: false, completion: nil)
        setNavigationTitle(date: date)
    }
    
    
    var orderedViewControllers: [HomeViewController] = []
    
    func newVc(_ date: String?) -> HomeViewController {
        let viewController = UIStoryboard(name: "Tabs", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        if date != nil {
            viewController.highlow.date = date
        }
        
        return viewController
    }
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        let calendarIcon = UIImageView(image: UIImage(named: "calendar"))
        calendarIcon.frame.size = CGSize(width: 25, height: 25)
        calendarIcon.isUserInteractionEnabled = true
        calendarIcon.tintColor = .white
        let tapper = UITapGestureRecognizer(target: self, action: #selector(navigationBarTapped))
        calendarIcon.addGestureRecognizer(tapper)
        
        let barButtonItem = UIBarButtonItem(customView: calendarIcon)
        barButtonItem.target = self
        barButtonItem.action = #selector(navigationBarTapped)
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.barTintColor = .white
        
        // Instantiate gesture recognizer
        //tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(navigationBarTapped))
        
        dataSource = self
        delegate = self
        
        self.navigationItem.title = "Today"
        
        orderedViewControllers.append(newVc(nil))
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    
    // Action called when navigation bar is tapped anywhere
    @objc func navigationBarTapped(){
        // Here, we know that the user wanted to tap the navigation bar and not a control inside it
        let calendarViewController = UIStoryboard(name: "Tabs", bundle: nil).instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        calendarViewController.delegate = self
        calendarViewController.modalPresentationStyle = .pageSheet
        self.present(calendarViewController, animated: true)
        
    }
    
    
    
    
    
    
    
    func prettyFormat(_ dateString: String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        let otherDateFormatter = DateFormatter()
        otherDateFormatter.dateStyle = .medium
        otherDateFormatter.timeStyle = .none
        
        return otherDateFormatter.string(from: date)
        
    }
    
    
    func dayAfter(_ date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: date) else { return nil }
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return nil }
        
        return dateFormatter.string(from: newDate)
    }
    
    func dayBefore(_ date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: date) else { return nil }
        guard let newDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return nil }
        
        return dateFormatter.string(from: newDate)
    }
    
    func todayAsDateString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        
        return dateFormatter.string(from: today)
    }
    
}




extension HighLowPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        
        guard let homeViewController = viewController as? HomeViewController else { return nil }
        
        //guard let date = homeViewController.date ?? todayAsDateString() else { return nil }
        
        var date = ""
        
        
        if homeViewController.highlow.date == "" || homeViewController.highlow.date == nil {
            date = todayAsDateString() ?? ""
        } else {
            date = homeViewController.highlow.date!
        }
        
        if date == "" {
            return nil
        }
        
        
        guard let newDate = self.dayBefore(date) else {
            return nil
        }
        
        return newVc(newDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let homeViewController = viewController as? HomeViewController else { return nil }
        
        if homeViewController.highlow.date == nil || homeViewController.highlow.date == "" {
            homeViewController.highlow.date = todayAsDateString() ?? ""
            return nil
        } else {

            if homeViewController.highlow.date! == todayAsDateString()! {
                return nil
            }
            guard let newDate = self.dayAfter(homeViewController.highlow.date!) else { return nil }
            
            if newDate == todayAsDateString()! {
                return newVc(nil)
            }
            
            return newVc(newDate)
        }
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let homeViewController = self.viewControllers?.first as! HomeViewController
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
        
        if let date = homeViewController.highlow.date {
            setNavigationTitle(date: date)
        } else {
            self.navigationItem.title = "Today"
        }
    }
    
    func setNavigationTitle(date: String) {
        if date == todayAsDateString() {
            self.navigationItem.title = "Today"
        } else {
            self.navigationItem.title = prettyFormat(date) ?? "Today"
        }
    }
    
    
    
    
}
