//
//  InterestsPitchViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 12/23/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import TagListView

class InterestsPitchViewController: UIViewController, EditInterestViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        skipFunc()
    }
    
    func didDisappear() {
        skipFunc()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        let container = UIView()
        self.view.addSubview(container)
        
        container.centerY(self.view).eqWidth(self.view).centerX(self.view)
        
        let header = UILabel()
        header.text = "Tell us what you're interested in!"
        header.textColor = .black
        header.font = .systemFont(ofSize: 30, weight: .bold)
        header.textAlignment = .center
        header.numberOfLines = 0
        
        container.addSubview(header)
        
        header.eqWidth(container, 0.0, 0.7).centerX(container).eqTop(container)
        
        let subHeader = UILabel()
        subHeader.text = "We use this to help you connect with other users!"
        subHeader.textColor = .black
        subHeader.textAlignment = .center
        subHeader.numberOfLines = 0
        subHeader.font = .systemFont(ofSize: 20)
        
        container.addSubview(subHeader)
        
        subHeader.topToBottom(header, 20).eqWidth(container, 0.0, 0.8).centerX(container)
        
        let buttons = UIStackView()
        buttons.axis = .horizontal
        buttons.distribution = .fillProportionally
        
        container.addSubview(buttons)
        
        buttons.eqWidth(subHeader).topToBottom(subHeader, 20).centerX(container).height(40)
        
        let absolutely = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        
        absolutely.title = "Absolutely!"
        absolutely.colorStyle = "pink"
        absolutely.height(40)
        
        absolutely.addTarget(self, action: #selector(absolutelyFunc), for: .touchUpInside)
        
        buttons.addArrangedSubview(absolutely)
        
        let skip = HLButton(frame: .zero)
        skip.gradientOn = false
        skip.title = "Later"
        skip.colorStyle = "white"
        skip.addTarget(self, action: #selector(skipFunc), for: .touchUpInside)
        
        buttons.addArrangedSubview(skip)
        
        container.eqBottom(buttons)
        
        
        
    }
    
    
    
    @objc func absolutelyFunc() {
        let editInterestsViewController = EditInterestsViewController()
        let navigationController = UINavigationController(rootViewController: editInterestsViewController)
        
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.barTintColor = AppColors.primary
        navigationController.navigationBar.isTranslucent = false
        navigationController.presentationController?.delegate = self
        
        editInterestsViewController.delegate = self
        
        self.present(navigationController, animated: true)
    }
    
    @objc func skipFunc() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasPassedInterestsScreen")
        switchToMain()
    }
    
}
