//
//  Pitch.swift
//  Crescendo
//
//  Created by Daniel Kuntz on 4/8/17.
//  Copyright © 2017 Pulse Technologies. All rights reserved.
//

import Foundation

class Pitch: Comparable {
    
    /**
     * The step is one of C, C#, D, D#, E, F, F#, G, G#, A, A#, B.
     */
    let step: Step

    /**
     * The octave is a whole integer between 2 and 9.
     */
    let octave: Int

    /**
     * The frequency is a floating point integer according to the International
     * Scientific Pitch Notation table.
     */
    var frequency: Double {
        return step.frequency * pow(2, Double(octave) - 4)
    }

    init(step: Step, octave: Int) {
        self.step = step
        self.octave = octave
    }
    
    init(_ step: Step) {
        self.step = step
        self.octave = 4
    }
    
    init(midiNoteNumber: Int) {
        self.step = Step.all[midiNoteNumber % 12]
        self.octave = (midiNoteNumber / 12)
    }
    
    static func rest() -> Pitch {
        return Pitch(.rest)
    }

    /**
     * This array contains all pitches for all steps in the 0 to 7 octaves.
     * First, the octaves are mapped to arrays of pitches for each step within
     * each octave.
     */
    static let all = Array((2 ... 7).map { octave -> [Pitch] in
        Step.all.map { step -> Pitch in
            Pitch(step: step, octave: octave)
        }
    }.joined())
    
//    /**
//     * Returns a random pitch.
//     */
//    static func random() -> Pitch {
//        let randomNote = Step(rawValue: randInRange(0...11))
//        return Pitch(step: randomNote!, octave: 4)
//    }

    /**
     * This function returns the nearest pitch to the given frequency in Hz.
     */
    class func nearest(frequency: Double) -> Pitch {
        /* Map all pitches to tuples of the pitch and the distance between the
         * frequency for that pitch and the given frequency. */
        var results = all.map { pitch -> (pitch: Pitch, distance: Double) in
            (pitch: pitch, distance: abs(pitch.frequency - frequency))
        }

        /* Sort array based on distance. */
        results.sort { $0.distance < $1.distance }

        /* Return the first result (i.e. nearest pitch). */
        return results.first!.pitch
    }

    /**
     * This property is used in the User Interface to show the "name" of this
     * pitch.
     */
    var description: String {
        if step == .rest {
            return "\(step)"
        }
        
        return "\(step)\(octave)"
    }
    
    /**
     * The MIDI note number that corresponds to this pitch.
     */
    var midiNoteNumber: UInt8 {
        if let index = Step.all.index(of: step) {
            return UInt8(index + octave * 12)
        }
        
        return 12
    }
}

/**
 * We override the equality operator so we can use `indexOf` on the static array
 * of all pitches. Using the `description` property isn't the most idiomatic way
 * to do this but it does the job.
 */
func ==(a: Pitch, b: Pitch) -> Bool {
    return a.description == b.description && a.octave == b.octave
}

func !=(a: Pitch, b: Pitch) -> Bool {
    return !(a == b)
}

// MARK: - Comparable

func <=(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs < rhs || lhs == rhs
}

func >=(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs > rhs || lhs == rhs
}

func >(lhs: Pitch, rhs: Pitch) -> Bool {
    if lhs.octave == rhs.octave {
        if let lhsI = Step.all.index(of: lhs.step),
            let rhsI = Step.all.index(of: rhs.step) {
            return lhsI > rhsI
        }
        
        return false
    }
    
    return lhs.octave > rhs.octave
}

func <(lhs: Pitch, rhs: Pitch) -> Bool {
    if lhs.octave == rhs.octave {
        if let lhsI = Step.all.index(of: lhs.step),
            let rhsI = Step.all.index(of: rhs.step) {
            return lhsI < rhsI
        }
        
        return false
    }
    
    return lhs.octave < rhs.octave
}

/**
 * We override the add operator so we can get to the next (or previous) pitches
 * simply by adding or subtracting an int to or from the pitch.
 */
func +(pitch: Pitch, offset: Int) -> Pitch {
    let all   = Pitch.all
    if var index = all.index(where: { $0 == pitch }) {
        index += offset
        return all[(index % all.count + all.count) % all.count]
    }

    return pitch
}

/**
 * Lastly, we need to override the - operator too but we can simply call +
 * with a negative offset.
 */
func -(pitch: Pitch, offset: Int) -> Pitch { return pitch + (-offset) }
