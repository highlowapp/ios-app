//
//  ThemeControlTableViewCell.swift
//  HighLow
//
//  Created by Caleb Hester on 3/31/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ThemeControlTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let segmentedControl = UISegmentedControl(items: ["Light", "Auto", "Dark"])
        
        self.textLabel?.text = "Theme"
        
        self.contentView.addSubview(segmentedControl)
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], for: .normal)
        
        segmentedControl.tintColor = AppColors.primary
        
        switch themeOverride() {
            case "light":
                segmentedControl.selectedSegmentIndex = 0
            break
            case "auto":
                segmentedControl.selectedSegmentIndex = 1
            break
            default:
                segmentedControl.selectedSegmentIndex = 2
            break
        }
        
        segmentedControl.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        
        segmentedControl.eqTrailing(self.contentView, -10)
        segmentedControl.eqTop(self.contentView, 10)
        self.contentView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        awakeFromNib()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc func themeChanged(_ sender: UISegmentedControl) {
        var theme = "auto"
        if sender.selectedSegmentIndex == 0 {
            theme = "light"
        }
        else if sender.selectedSegmentIndex == 2 {
            theme = "dark"
        }

        if theme == "auto" {
            UserDefaults.standard.removeObject(forKey: "com.gethighlow.interfaceStyle")
        } else {
            UserDefaults.standard.set(theme, forKey: "com.gethighlow.interfaceStyle")
        }
        NotificationCenter.default.post(name: Notification.Name("com.gethighlow.themeChanged"), object: nil, userInfo: ["theme":theme])
    }

}
