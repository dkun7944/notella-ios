//
//  UIColor+NotellaColors.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

extension UIColor {
    @nonobjc static let notellaPurple: UIColor = UIColor(realRed: 144, green: 19, blue: 254, alpha: 1.0)
    @nonobjc static let lighterGray: UIColor = UIColor(white: 0.92, alpha: 1.0)
    
    @nonobjc convenience init(realRed: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: realRed/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
