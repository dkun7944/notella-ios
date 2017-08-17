//
//  Extensions.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Int {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var float: Float {
        return Float(self)
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

func randInRange(_ range: CountableClosedRange<Int>) -> Int {
    // arc4random_uniform(_: UInt32) returns UInt32, so it needs explicit type conversion to Int
    // note that the random number is unsigned so we don't have to worry that the modulo
    // operation can have a negative output
    return Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
}
