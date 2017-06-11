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
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let boundingRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.circleLayer.path = UIBezierPath(ovalIn: boundingRect).cgPath
        self.layer.addSublayer(self.circleLayer)
        
        self.circleLayer.strokeColor = self.color
        self.circleLayer.fillColor = self.color
        self.circleLayer.lineWidth = 2.0
    }
    
    func pulse() {
        self.circleLayer.strokeColor = color
        
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
        sizeEnd.toValue = UIBezierPath(ovalIn: CGRect(x: -200, y: -200, width: 640, height: 640)).cgPath
        
        let opacityStart = CABasicAnimation(keyPath: "opacity")
        opacityStart.toValue = 1.0
        let opacityEnd = CABasicAnimation(keyPath: "opacity")
        opacityEnd.toValue = 0.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [sizeStart, sizeEnd, opacityStart, opacityEnd]
        animationGroup.duration = 1.0
        animationGroup.autoreverses = false
        
        newCircleLayer.add(animationGroup, forKey: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85, execute: {
            newCircleLayer.opacity = 0.0
        })
        
        CATransaction.commit()
        
        let widthStart = CABasicAnimation(keyPath: "lineWidth")
        widthStart.toValue = 2.0
        let widthEnd = CABasicAnimation(keyPath: "lineWidth")
        widthEnd.toValue = 20.0
        
        let width = CAAnimationGroup()
        width.animations = [widthStart, widthEnd]
        width.autoreverses = true
        
        if self.tempo < 180 {
            width.duration = 0.1
        } else {
            width.duration = 0.075
        }
        
        self.circleLayer.add(width, forKey: nil)
    }
}
