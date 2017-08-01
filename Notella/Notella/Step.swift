//
//  Step.swift
//  Crescendo
//
//  Created by Daniel Kuntz on 4/8/17.
//  Copyright © 2017 Pulse Technologies. All rights reserved.
//

import Foundation

enum Step: Int, CustomStringConvertible {
    case csharp
    case d
    case dsharp
    case e
    case f
    case fsharp
    case g
    case gsharp
    case a
    case asharp
    case b
    case c
    
    case rest

    /**
     * This array contains all steps.
     */
    static let all: [Step] = [.c, .csharp, .d, .dsharp, .e, .f, .fsharp, .g, .gsharp, .a, .asharp, .b]
    
    /**
     * Initializes a new Step from a given name.
     */
    static func fromName(_ name: String) -> Step? {
        var stepName = name
        if stepName == "C♭" { stepName = "B" }
        if stepName == "B♯" { stepName = "C" }
        if stepName == "F♭" { stepName = "E" }
        if stepName == "E♯" { stepName = "F" }
        
        return all.filter { note in
            return stepName == note.sharpName || stepName == note.flatName
        }.first
    }
    
    /**
     * Initializes a new Step from a given name and an alteration (1, 0, -1, etc.)
     */
    static func fromName(_ name: String, alter: Int) -> Step? {
        guard let step = Step.fromName(name) else { return nil }
        var index = Int(all.index(of: step)!)
        index += alter
        
        if index >= all.count {
            index = Int(index / all.count) + abs(index) % all.count
        } else if index < 0 {
            index = all.count - (Int(index / all.count) + abs(index) % all.count)
        }
        
        return Step.all[index]
    }
    
    func withoutAccidental() -> Step {
        let name = self.sharpName.substring(to: sharpName.index(sharpName.startIndex, offsetBy: 1))
        return Step.fromName(name)!
    }
    
    func accidental() -> String {
        if flatName.characters.count > 1 {
            return String(flatName.characters.last!)
        }
        return ""
    }
    
    /**
     * How far a particular step is from C.
     */
    var concertOffset: Int {
        return self.rawValue - 11
    }
    
    /**
     * concertOffset formatted as a string (i.e "+2" or "-5")
     */
    var concertOffsetString: String {
        if concertOffset == 0 { return "concert" }
        return concertOffset < 0 ? "\(concertOffset)" : "+\(concertOffset)"
    }

    /**
     * Returns the frequency of this step in the 4th octave.
     */
    var frequency: Double {
        if self == .rest {
            return 0.0
        }
        
        let index = Step.all.index(where: { $0 == self })! -
                    Step.all.index(where: { $0 == Step.a })!
        
        return 440 * pow(2, Double(index) / 12.0)
    }

    /**
     * This property is used in the User Interface to show the name of this
     * note.
     */
    var description: String {
        return flatName
    }
    
    fileprivate var sharpName: String {
        switch self {
        case .a:
            return "A"
        case .asharp:
            return "A♯"
        case .b:
            return "B"
        case .c:
            return "C"
        case .csharp:
            return "C♯"
        case .d:
            return "D"
        case .dsharp:
            return "D♯"
        case .e:
            return "E"
        case .f:
            return "F"
        case .fsharp:
            return "F♯"
        case .g:
            return "G"
        case .gsharp:
            return "G♯"
        case .rest:
            return "Rest"
        }
    }

    fileprivate var flatName: String {
        switch self {
        case .a, .b, .c, .d, .e, .f, .g, .rest:
            return sharpName
        case .asharp:
            return "B♭"
        case .csharp:
            return "D♭"
        case .dsharp:
            return "E♭"
        case .fsharp:
            return "G♭"
        case .gsharp:
            return "A♭"
        }
    }
}

/**
 * We override the equality operator so we can use `indexOf` on the static array
 * of all notes. Using the `description` property isn't the most idiomatic way
 * to do this but it does the job.
 */
func ==(a: Step, b: Step) -> Bool {
    return a.sharpName == b.sharpName
}
