//
//  GradientUIView.swift
//  HighLow
//
//  Created by Caleb Hester on 5/25/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

@IBDesignable
class GradientUIView: UIView {
    
    
    @IBInspectable var startColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    
    
    @IBInspectable var angle: CGFloat = 270 {
        didSet {
            updateGradient()
        }
    }
    
    
    private var gradient: CAGradientLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        installGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        installGradient()
    }
    
    
    private func installGradient() {

        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        
        let gradient = createGradient()
        
        conditionalGradSetup()
        self.gradient = gradient
    }
    
    private func conditionalGradSetup() {
        switch themeOverride() {
        case "dark":
            self.backgroundColor = .black
        break
        case "light":
            let gradient = createGradient()
            self.layer.insertSublayer(gradient, at: 0)
        break
        default:
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                self.backgroundColor = .black
            } else {
                let gradient = createGradient()
                self.layer.insertSublayer(gradient, at: 0)
            }
        break
        }
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
        gradient.frame = self.bounds
        return gradient
    }
    
    
    private func gradientPointsForAngle(_ angle: CGFloat) -> (CGPoint, CGPoint) {

        let end = pointForAngle(angle)
   
        let start = oppositePoint(end)
    
        let p0 = transformToGradientSpace(start)
        let p1 = transformToGradientSpace(end)
        
        return (p0, p1)
    }
    
    override func updateColors() {
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.removeFromSuperlayer()
        gradient!.frame = self.bounds
        self.backgroundColor = .white
        switch themeOverride() {
        case "dark":
            self.backgroundColor = .black
        break
        case "light":
            self.layer.insertSublayer(gradient!, at: 0)
        break
        default:
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                self.backgroundColor = .black
            } else {
                self.layer.insertSublayer(gradient!, at: 0)
            }
        break
        }
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
