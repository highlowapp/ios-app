//
//  HLTextField.swift
//  HighLow
//
//  Created by Caleb Hester on 5/25/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

@IBDesignable
class HLTextField: UIView {
    
    var textField: UITextField = UITextField()
    
    let gradient = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let gradientLayer = CAGradientLayer()
    
    var isPassword: Bool = false {
        didSet {
            textField.isSecureTextEntry = isPassword
        }
    }
    
    @IBInspectable var placeholder: String = "Untitled Input" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.lightGray])
        }
    }
    
    @IBInspectable var lightMode: Bool = false {
        didSet {
            if lightMode {
                self.lightModeOn()
            } else {
                self.setup()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func lightModeOn() {
        gradientLayer.removeFromSuperlayer()
        self.layer.cornerRadius = 5.0
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !lightMode {
            roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
        }
        
        gradientLayer.frame = gradient.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    
    private func setup() {
        //self.layer.cornerRadius = 10
        self.backgroundColor = rgb(240, 240, 240)
        
        textField.textColor = .black
        
        //UITextView
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(
                item: textField,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: textField,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: textField,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1,
                constant: -30
            )
        ]
        
        self.addSubview(textField)
        
        self.addConstraints(constraints)
        
        
        
        textField.returnKeyType = .done
        
        
        
        
        //Gradient
        gradientLayer.frame = gradient.bounds
        
        gradientLayer.colors = [ rgb(247, 14, 69).cgColor, rgb(247, 136, 24).cgColor ]
        
        gradient.layer.insertSublayer(gradientLayer, at: 0)
        
        
        gradient.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(
                item: gradient,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: gradient,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: gradient,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: gradient,
                attribute: .height,
                relatedBy: .equal,
                toItem: self,
                attribute: .height,
                multiplier: 0,
                constant: 3
            )
        ]
        
        
        self.addSubview(gradient)
        self.addConstraints(gradientConstraints)
        
        themeSwitch(onDark: {
            lightModeOn()
        }, onLight: {
        }, onAuto: {
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                lightModeOn()
            }
        })
        
        
        
    }
    
}







extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
