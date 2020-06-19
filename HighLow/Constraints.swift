//
//  Constraints.swift
//  HighLow
//
//  Created by Caleb Hester on 12/19/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult
    func topToBottom(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func bottomToTop(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: item, attribute: .top, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func leadingToTrailing(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: item, attribute: .trailing, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func trailingToLeading(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: item, attribute: .leading, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func centerX(_ item: UIView) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: item, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        return self
    }
    @discardableResult
    func centerY(_ item: UIView) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: item, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        return self
    }
    @discardableResult
    func eqWidth(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: item, attribute: .width, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqHeight(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: item, attribute: .height, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqLeading(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: item, attribute: .leading, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqTrailing(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: item, attribute: .trailing, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqTop(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: item, attribute: .top, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func eqBottom(_ item: UIView, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func height(_ constant: CGFloat) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    @discardableResult
    func width(_ constant: CGFloat) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func aspectRatioFromWidth(_ constant: CGFloat) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: constant).isActive = true
        return self
    }
    
    @discardableResult
    func aspectRatioFromHeight(_ constant: CGFloat) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: constant).isActive = true
        return self
    }
    
    
    
    
    
    
    
    
    
    @discardableResult
    func topToBottom(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func bottomToTop(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: item, attribute: .top, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func leadingToTrailing(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: item, attribute: .trailing, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func trailingToLeading(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: item, attribute: .leading, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func centerX(_ item: UILayoutGuide) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: item, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        return self
    }
    @discardableResult
    func centerY(_ item: UILayoutGuide) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: item, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        return self
    }
    @discardableResult
    func eqWidth(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: item, attribute: .width, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqHeight(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: item, attribute: .height, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqLeading(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: item, attribute: .leading, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqTrailing(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: item, attribute: .trailing, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    @discardableResult
    func eqTop(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: item, attribute: .top, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func eqBottom(_ item: UILayoutGuide, _ constant: CGFloat = 0.0, _ multiplier: CGFloat = 1.0) -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: item, attribute: .bottom, multiplier: multiplier, constant: constant).isActive = true
        return self
    }
    

}

extension NSLayoutYAxisAnchor {
    func link(_ to: NSLayoutYAxisAnchor) {
        self.constraint(equalTo: to).isActive = true
    }
}

extension NSLayoutXAxisAnchor {
    func link(_ to: NSLayoutXAxisAnchor) {
        self.constraint(equalTo: to).isActive = true
    }
}
