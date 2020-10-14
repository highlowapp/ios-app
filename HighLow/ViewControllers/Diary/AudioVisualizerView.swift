//
//  AudioVisualizerView.swift
//  HighLow
//
//  Created by Caleb Hester on 8/1/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class AudioVisualizerView: UIView {
    override class var layerClass: AnyClass {
        return AudioVisualizerLayer.self
    }
    
    private var audioLayer: AudioVisualizerLayer {
        return self.layer as! AudioVisualizerLayer
    }
    
    var peakValue: CGFloat {
        get {
            return audioLayer.peakValue
        }
        set {
            audioLayer.peakValue = newValue
            audioLayer.setNeedsDisplay()
        }
    }
    var avgValue: CGFloat {
        get {
            return audioLayer.avgValue
        }
        set {
            audioLayer.avgValue = newValue
            audioLayer.setNeedsDisplay()
        }
    }
    
    weak var delegate: AudioVisualizerViewDelegate?
    
    func setMeters(peak: CGFloat, avg: CGFloat) {
        /*let anim1 = CAKeyframeAnimation(keyPath: #keyPath(AudioVisualizerLayer.peakValue))
        let anim2 = CAKeyframeAnimation(keyPath: #keyPath(AudioVisualizerLayer.avgValue))
        anim1.values = [
            -160,
            peak,
            peak,
            -160
        ]
        anim2.values = [
            audioLayer.presentation()?.avgValue,
            avg
        ]
        anim1.keyTimes = [0, 0.5, 0.75, 1]
        anim2.keyTimes = [0, 1]
        anim1.duration = 0.2
        anim2.duration = 0.2
        audioLayer.add(anim1, forKey: #keyPath(AudioVisualizerLayer.peakValue))
        audioLayer.add(anim2, forKey: #keyPath(AudioVisualizerLayer.avgValue))*/
        audioLayer.avgValue = avg
        audioLayer.setNeedsDisplay()
    }
}

protocol AudioVisualizerViewDelegate: AnyObject {
    func peakValue() -> CGFloat
}




class AudioVisualizerLayer: CALayer {
    @objc dynamic var peakValue: CGFloat = -160.0
    @objc dynamic var avgValue: CGFloat = -160.0
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
 
        if let other = layer as? AudioVisualizerLayer {
            self.peakValue = other.peakValue
            self.avgValue = other.avgValue
        }
        else {
            fatalError()
        }
        
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        let middle = self.bounds.width/2
        let midPoint = max(2, dBToFrameHeight( f(x: 0, peak: peakValue, avg: avgValue) ))
        ctx.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 - midPoint))
        ctx.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 + midPoint))
        
        let increment: CGFloat = 7
        var n: CGFloat = 1
        while middle - (increment * n) >= 0 {
            let value = max(2, dBToFrameHeight( f(x: n/2, peak: peakValue, avg: avgValue)))
            
            ctx.move(to: CGPoint(x: middle - (increment*n), y: self.bounds.height/2 - value))
            ctx.addLine(to: CGPoint(x: middle - (increment * n), y: self.bounds.height/2 + value))
            ctx.move(to: CGPoint(x: middle + (increment*n), y: self.bounds.height/2 - value))
            ctx.addLine(to: CGPoint(x: middle + (increment * n), y: self.bounds.height/2 + value))
            
            n += 1
        }
        ctx.setStrokeColor(AppColors.primary.cgColor)
        ctx.setLineWidth(2.0)
        ctx.drawPath(using: .stroke)
    }
    
    private func dBToFrameHeight(_ dB: CGFloat) -> CGFloat {
        let a = dB + 160
        let b = self.frame.height/2
        return a * b/160;
    }
    
    
    private func f(x: CGFloat, peak: CGFloat, avg: CGFloat) -> CGFloat {
        return bellCurve(x: x, p: peak, a: avg)
    }
    
    private func bellCurve(x: CGFloat, p: CGFloat, a: CGFloat) -> CGFloat {
        return (a+160) * pow(CGFloat(M_E),
            -pow(x * (a/3)/160, 2)
            ) - 160 + CGFloat.random(in: -3..<3) / (a/160 + 0.001)
    }
    
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(AudioVisualizerLayer.peakValue) || key == #keyPath(AudioVisualizerLayer.avgValue) {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        /*
        if event == #keyPath(AudioVisualizerLayer.peakValue) {
            let anim = CABasicAnimation(keyPath: #keyPath(AudioVisualizerLayer.peakValue))
            anim.byValue = 0.01
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.fromValue = presentation()?.peakValue ?? -160
            return anim
        }
        
        if event == #keyPath(AudioVisualizerLayer.avgValue) {
            let anim = CABasicAnimation(keyPath: #keyPath(AudioVisualizerLayer.avgValue))
            anim.byValue = 0.01
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.fromValue = presentation()?.avgValue ?? -160
            return anim
        }*/
        return super.action(forKey: event)
    }
    
}
