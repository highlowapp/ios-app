//
//  Extensions.swift
//  HighLow
//
//  Created by Caleb Hester on 7/30/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.view.addSubview(subview)
        }
    }
}

extension UIView {
    @objc func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addSubview(subview)
        }
    }
}

extension UITableViewCell {
    override func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.contentView.addSubview(subview)
        }
    }
}
