//
//  RandomMusic.swift
//  Notella
//
//  Created by Daniel Kuntz on 8/1/17.
//  Copyright © 2017 Daniel Kuntz. All rights reserved.
//

import Foundation

struct ScoreSystem {
    var clef: String
    var time: String
    var notes: [ScoreNote]
}

struct ScoreNote {
    var step: String
    var accidental: String
    var octave: Int
    var duration: Float
    
    var isEighth: Bool {
        return duration == 0.5
    }
    
    var isSixteenth: Bool {
        return duration == 0.25
    }
    
    var hasDot: Bool {
        switch duration {
        case 0.125, 0.25, 0.5, 1.0, 2.0, 4.0:
            return false
        default:
            return true
        }
    }
    
    var type: String {
        switch duration {
        case 0.125:
            return "32nd"
        case 0.25:
            return "16th"
        case 0.5, 0.75:
            return "eighth"
        case 1.0, 1.5:
            return "quarter"
        case 2.0, 3.0:
            return "half"
        case 4.0, 6.0:
            return "whole"
        default:
            return "quarter"
        }
    }
}

class RandomMusic {
    
    static var measures = 18
    static var numerator = 3
    static var denominator = 4
    static var octaves = 2
    static var key = 3
    
    static func generate() -> ScoreSystem {
        let realMeasures = ceil(Double(measures * denominator / numerator))
        let numNotes = realMeasures * 4 //number of 1/4th notes
        var notes: [ScoreNote] = []
        
        [0..<numNotes].forEach { _ in
            if drand48() < 0.5 {
                notes.append(randomNote(duration: 2))
                notes.append(randomNote(duration: 2))
            } else {
                notes.append(randomNote(duration: 4))
            }
        }
        
        let time: String = "\(numerator)\(denominator)"
        let system = ScoreSystem(clef: "g_clef", time: time, notes: notes)
        return system
    }
    
    static func randomNote(duration: Float) -> ScoreNote {
        let pitch = randomPitch()
        let step = pitch.step.withoutAccidental().description
        let accidental = pitch.step.accidental()
        return ScoreNote(step: step, accidental: accidental, octave: pitch.octave, duration: duration)
    }
    
    static func randomPitch() -> Pitch {
        var cdur = [ 0, 2, 4, 5, 7, 9, 11 ]
        //           c  g  d  e
        var keyo = [ 0, 7, 2, 4 ]
        
        let idx    = Int(arc4random_uniform(6))
        let octave = Int(arc4random_uniform(2))
        let midiNote  = (cdur[idx] + octave * 12 + 60) + keyo[key]
        
        return Pitch(midiNoteNumber: midiNote)
    }
    
}
