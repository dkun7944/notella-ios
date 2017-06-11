//
//  PulsatingView.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

class PulsatingView: UIView {
    
    // MARK: - Variables
    
    var color: CGColor = UIColor.notellaPurple.cgColor
    var circleLayer: CAShapeLayer = CAShapeLayer()
    var tempo: Int = 120
    
    // MARK: - Setup
    
    init(frame: CGRect, color: UIColor) {
        self.color = color.cgColor
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.circleLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.circleLayer.fillColor = UIColor.lighterGray.cgColor
        self.layer.addSublayer(self.circleLayer)
    }
    
    func pulse() {
        CATransaction.begin()
        let newCircleLayer = CAShapeLayer()
        newCircleLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.addSublayer(newCircleLayer)
        
        CATransaction.setCompletionBlock({
            newCircleLayer.removeFromSuperlayer()
        })
        
        newCircleLayer.strokeColor = color
        newCircleLayer.fillColor = color
        
        let sizeStart = CABasicAnimation(keyPath: "path")
        sizeStart.toValue = newCircleLayer.path
        let sizeEnd = CABasicAnimation(keyPath: "path")
        
        let inset = -bounds.width
        sizeEnd.toValue = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset)).cgPath
        
        let opacityStart = CABasicAnimation(keyPath: "opacity")
        opacityStart.toValue = 5.0
        let opacityEnd = CABasicAnimation(keyPath: "opacity")
        opacityEnd.toValue = 0.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [sizeStart, sizeEnd, opacityStart, opacityEnd]
        animationGroup.duration = 1.0
        animationGroup.autoreverses = false
        
        newCircleLayer.opacity = 0.0
        newCircleLayer.add(animationGroup, forKey: nil)
        
        CATransaction.commit()
        
//        let widthStart = CABasicAnimation(keyPath: "lineWidth")
//        widthStart.toValue = 2.0
//        let widthEnd = CABasicAnimation(keyPath: "lineWidth")
//        widthEnd.toValue = 20.0
//        
//        let width = CAAnimationGroup()
//        width.animations = [widthStart, widthEnd]
//        width.autoreverses = true
//        
//        if self.tempo < 180 {
//            width.duration = 0.1
//        } else {
//            width.duration = 0.075
//        }
//        
//        self.circleLayer.add(width, forKey: nil)
    }
}
