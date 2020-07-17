//
//  ActivityChartCell.swift
//  HighLow
//
//  Created by Caleb Hester on 6/23/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ActivityChartCell: CardTableViewCell {
    
    var chartData: [NSDictionary] = []
    let chartView: ActivityChart = ActivityChart()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let yourActivity = UILabel()
        contView.addSubview(yourActivity)
        
        yourActivity.text = "Your Activity"
        yourActivity.font = .systemFont(ofSize: 20)
        yourActivity.eqLeading(contView, 20).eqTop(contView, 20)
        yourActivity.sizeToFit()
        
        contView.addSubview(chartView)
        
        chartView.eqWidth(contView, -40).centerX(contView).height(100).topToBottom(yourActivity, 20)
        chartView.backgroundColor = rgb(245, 245, 245)
        chartView.setChartData(chartData)
        
        contView.eqBottom(chartView, 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setChartData(_ data: [NSDictionary]) {
        self.chartData = data
        chartView.setChartData(chartData)
    }
}

class ActivityChart: UIView {
    
    private var shapeLayer: CALayer?
    var chartData: [NSDictionary] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private  func setup() {
        
    }
    
    func setChartData(_ data: [NSDictionary]) {
        self.chartData = data
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.fillColor = rgba(69, 246, 76, 0.3).cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = rgb(69, 246, 76).cgColor
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
        self.shapeLayer?.shadowColor = UIColor.black.cgColor
        self.shapeLayer?.shadowOffset = CGSize(width: 0, height: 10)
        self.shapeLayer?.shadowRadius = 10
        self.shapeLayer?.shadowOpacity = 0.2
    }
    
    private func createPath() -> CGMutablePath {
        let path = CGMutablePath()
        let interval = self.chartData.count > 0 ? self.frame.width / CGFloat(self.chartData.count - 1):self.frame.width
        
        path.move(to: CGPoint(x: 0, y: self.frame.height))
            
        if self.chartData.count == 0 {
            path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            return path
        }
        
        let maxItem = self.chartData.max { a, b in
            let n1 = a["activities"] as! Int
            let n2 = b["activities"] as! Int
            return n1 < n2
        }
        let maxHeight = self.frame.height - 10
        let maxValue = maxItem!["activities"] as! Int

        
                
        for i in 0..<self.chartData.count {
            let value = self.chartData[i]["activities"] as! Int
            
            
            if maxValue == 0 {
                let newPoint = CGPoint(x: interval * CGFloat(i), y: self.frame.height)
                
                if i > 0 {
                    path.addCurve(to: newPoint, control1: CGPoint(x: newPoint.x - interval/2, y: path.currentPoint.y), control2: CGPoint(x: newPoint.x - interval/2, y: newPoint.y))
                } else {
                    path.addLine(to: newPoint)
                }
            }
            else {
                let newPoint = CGPoint(x: interval * CGFloat(i), y: ( (maxHeight + 20) - max(10, maxHeight * CGFloat((value / maxValue)))  ))
                if i > 0 {
                    path.addCurve(to: newPoint, control1: CGPoint(x: newPoint.x - interval/2, y: path.currentPoint.y), control2: CGPoint(x: newPoint.x - interval/2, y: newPoint.y))
                } else {
                    path.addLine(to: newPoint)
                }
            }
        }
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        
        return path
    }
}
