//
//  PulsatingViewCollection.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

class PulsatingViewCollection: UIView {
    
    // MARK: - Properties
    
    let viewDiameter: CGFloat = 10.0
    var views: [PulsatingView] = []
    var numViews: Int = 4 {
        didSet {
            setup()
        }
    }
    
    var beat: Int = 0
    
    // MARK: - Setup
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup() {
        for view in views {
            view.removeFromSuperview()
        }
        views.removeAll()
        
        let spacing = (bounds.width - (numViews.cgFloat * viewDiameter)) / (numViews.cgFloat - 1)
        let y = (bounds.height / 2) - (viewDiameter / 2)
        for i in 0..<numViews {
            let x = (i.cgFloat * viewDiameter) + (i.cgFloat * spacing)
            let frame = CGRect(x: x, y: y, width: viewDiameter, height: viewDiameter)
            let newView = PulsatingView(frame: frame)
            views.append(newView)
            addSubview(newView)
        }
    }
    
    // MARK: - Actions
    
    func pulse(beat: Int) {
        self.beat = beat.clamped(to: 0...numViews-1)
        views[beat].pulse()
    }
    
    func pulseNext() {
        beat += 1
        if beat >= numViews {
            beat = 0
        }
        
        views[beat].pulse()
    }
}
