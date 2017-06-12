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
    
    @IBOutlet var pulsatingViewCollection: PulsatingViewCollection!
    @IBOutlet weak var scoreView: ScoreView!
    
    // MARK: - Properties
    
    var metronome: Metronome!
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderScore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let offset = CGPoint(x: 400, y: 0)
        scoreView.collectionView.setContentOffset(offset, animated: true)
    }

    func setup() {
        metronome = Metronome.init()
        metronome.delegate = self
        metronome.tempo = 120
    }
    
    func renderScore() {
        let xmlPath = Bundle.main.path(forResource: "twinkle", ofType: "xml")
        scoreView.setup(withXmlPath: xmlPath)
    }
    
    // MARK: - TempoDelegate Methods
    
    func pulseDownbeat() {
        pulse()
    }
    
    func pulseUpbeat() {
        pulse()
    }
    
    func pulse() {
        DispatchQueue.main.async {
            let beat = Int(self.metronome.currentBeat)
            self.pulsatingViewCollection.pulse(beat: beat)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startStopPressed(_ sender: Any) {
        metronome.on ? metronome.stopTapping() : metronome.startTapping()
    }
    
}
