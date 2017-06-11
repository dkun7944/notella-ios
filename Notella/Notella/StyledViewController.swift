//
//  StyledViewController.swift
//  Pitch
//
//  UIViewController subclass with corner radius and hidden status bar.
//  This is the basis for all other view controllers in Pitch.
//
//  Created by Daniel Kuntz on 3/18/17.
//  Copyright © 2017 Plutonium Apps. All rights reserved.
//

import UIKit

class StyledViewController: UIViewController {

    // MARK: - Status Bar Style
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
