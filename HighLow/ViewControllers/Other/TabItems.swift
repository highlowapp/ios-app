//
//  TabItems.swift
//  HighLow
//
//  Created by Caleb Hester on 6/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

enum TabItem: String, CaseIterable {
    case home = "home"
    case profile = "profile"
    case diary = "diary"
    case settings = "settings"
    
    var viewController: UIViewController {
        switch self {
        case .home:
            return NewFeedViewController()
        case .profile:
            return NewProfileViewController()
        case .diary:
            return NewDiaryViewController()
        case .settings:
            return NewSettingsViewController()
        }
    }
    
    var icon: UIImage {
        switch self {
        case .home:
            return UIImage(named: "NewHome")!
        case .profile:
            return UIImage(named: "NewProfile")!
        case .diary:
            return UIImage(named: "NewDiary")!
        case .settings:
            return UIImage(named: "NewSettings")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}

class TabBarItem: UIView {
    var title: String = ""
    var image: UIImage = UIImage()
    var viewController: UIViewController = UIViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    convenience init(tabItem: TabItem) {
        self.init()
        title = tabItem.displayTitle
        image = tabItem.icon
        viewController = tabItem.viewController
        
        setup()
    }
    
    private func setup() {
        let icon = UIImageView(image: image)
        let title = UILabel()
        title.text = self.title
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 13)
        title.textColor = UIColor.lightGray
        
        self.addSubview(icon)
        self.addSubview(title)
        
        icon.eqTop(self, 7).centerX(self).height(35).width(35)
        title.topToBottom(icon).eqWidth(self).centerX(self).eqBottom(self)
    }
}
