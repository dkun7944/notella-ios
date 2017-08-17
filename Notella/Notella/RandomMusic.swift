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
    static var key = 0
    static var maxLeap = 6
    
    static var keyo = [ 0, 7, 2, 4 ]
    
    static func generate() -> ScoreSystem {
        let durations: [Float] = [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0]
        let maxOctave = 52 + octaves * 12 + keyo[key]
        var notes: [ScoreNote] = []
        var prevMidiNote: Int = 0
        
        for _ in 0..<measures {
            var remaining: Float = numerator.float
            while remaining > 0 {
                let tmpDurations = durations.filter { $0 <= remaining }
                let duration = tmpDurations.randomItem()
                remaining -= duration
                
                var pitch: Pitch
                if prevMidiNote == 0 {
                    pitch = randomPitch(range: 0...127)
                } else {
                    pitch = randomPitch(range: prevMidiNote-maxLeap...min(prevMidiNote+maxLeap, maxOctave))
                }
                prevMidiNote = Int(pitch.midiNoteNumber)
                
                let note = pitchToScoreNote(pitch, duration: duration)
                notes.append(note)
            }
        }

        let time: String = "\(numerator)\(denominator)"
        let system = ScoreSystem(clef: "g_clef", time: time, notes: notes)
        return system
    }
    
    static func pitchToScoreNote(_ pitch: Pitch, duration: Float) -> ScoreNote {
        let step = pitch.step.withoutAccidental().description
        let accidental = pitch.step.accidental()
        return ScoreNote(step: step, accidental: accidental, octave: pitch.octave, duration: duration)
    }
    
    static func randomPitch(range: CountableClosedRange<Int>) -> Pitch {
        var cdur = [ 0, 2, 4, 5, 7, 9, 11 ]

        var midiNote = -1
        while !range.contains(midiNote) {
            midiNote = (cdur.randomItem() + randInRange(0...2) * 12 + 52) + keyo[key]
        }
        
        return Pitch(midiNoteNumber: midiNote)
    }
    
}
