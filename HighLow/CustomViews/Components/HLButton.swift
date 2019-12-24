//
//  HLButton.swift
//  HighLow
//
//  Created by Caleb Hester on 5/29/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

@IBDesignable
class HLButton: UIButton {
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    @IBInspectable var title: String = "Click Me!" {
        didSet {
            self.setTitle(title, for: .normal)
        }
    }
    
    @IBInspectable var colorStyle: String = "default" {
        didSet {
            self.setStyle(style: colorStyle)
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
    
    
    
    func setStyle(style: String) {
        
        switch(style) {
            
            case "white":
                gradientLayer.removeFromSuperlayer()
                self.backgroundColor = .white
                self.setTitleColor(UIColor(hexString: "#FB2A57"), for: .normal)
            
            case "pink":
                gradientLayer.removeFromSuperlayer()
                self.backgroundColor = UIColor(hexString: "#FB2A57")
                self.setTitleColor(.white, for: .normal)
            case "orange":
                gradientLayer.removeFromSuperlayer()
                self.backgroundColor = UIColor(hexString: "#FA9C1D")
                self.setTitleColor(.white, for: .normal)
            case "gray":
                gradientLayer.removeFromSuperlayer()
                self.backgroundColor = rgb(210, 210, 210)
                self.setTitleColor(.gray, for: .normal)
            default:
                gradientLayer = CAGradientLayer()
            
        }
    }
    
    var activityIndicator: UIActivityIndicatorView!
    
    
    func startLoading() {
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = .white
        }
        
        self.addSubview(activityIndicator)
        
        self.centerX(activityIndicator).centerY(activityIndicator)
        
        self.isEnabled = false
        
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        
        self.setTitle(title, for: .normal)
        
        self.isEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 0.5 * self.bounds.height
    }
    
    
    private func setup() {
        
        self.layer.cornerRadius = 0.5 * self.bounds.height
        self.setTitleColor(UIColor.white, for: .normal)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        
        gradientLayer.colors = [ rgb(247, 14, 69).cgColor, rgb(247, 136, 24).cgColor ]
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.cornerRadius = 0.5 * self.bounds.height
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

}




extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
