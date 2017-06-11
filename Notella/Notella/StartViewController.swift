//
//  StartViewController.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

class StartViewController: StyledViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var measureLabel: UILabel!
    
    // MARK: - Properties
    
    var numMeasures: Int = 16
    
    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        measureLabel.text = "\(numMeasures)"
    }

    // MARK: - Actions
    
    @IBAction func minusButtonPressed(_ sender: Any) {
        numMeasures = (numMeasures - 1).clamped(to: 4...96)
        measureLabel.text = "\(numMeasures)"
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        numMeasures = (numMeasures + 1).clamped(to: 4...96)
        measureLabel.text = "\(numMeasures)"
    }
}

