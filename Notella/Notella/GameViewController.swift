//
//  GameViewController.swift
//  Notella
//
//  Created by Daniel Kuntz on 6/11/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import UIKit

class GameViewController: StyledViewController {

    // MARK: - Outlets
    
    @IBOutlet var pulsatingView: PulsatingView!
    
    // MARK: - Properties
    
    var metronome: Metronome!
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        metronome = Metronome.init()
        metronome.delegate = self
        metronome.tempo = 120
    }
    
    // MARK: - TempoDelegate Methods
    
    func pulseDownbeat() {
        DispatchQueue.main.async {
            self.pulsatingView.pulse()
        }
    }
    
    func pulseUpbeat() {
        DispatchQueue.main.async {
            self.pulsatingView.pulse()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startStopPressed(_ sender: Any) {
        metronome.on ? metronome.stopTapping() : metronome.startTapping()
    }
    
}
