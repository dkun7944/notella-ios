//
//  Semantics+Generation.swift
//  MusicReader
//
//  Created by Daniel Kuntz on 6/22/17.
//  Copyright © 2017 Plutonium Apps. All rights reserved.
//

import Foundation

class XmlGenerator {
    
    static let divisions: Float = 4
    
    static func open(_ tag: String) -> String {
        return "<\(tag)>"
    }
    
    static func openNewline(_ tag: String) -> String {
        return "<\(tag)>\n"
    }
    
    static func close(_ tag: String) -> String {
        return "</\(tag)>\n"
    }
    
    static func autoClose(_ tag: String) -> String {
        return "<\(tag)/>\n"
    }
    
    static func timeToMusicXML(_ time: String) -> String {
        var beats: String = "4"
        var beatType: String = "4"
        
        if time.characters.count > 1 {
            beats = String(time.characters.first!)
            beatType = String(time.characters.last!)
        }
        
        return openNewline("time") + open("beats") + beats + close("beats") + open("beat-type") + beatType + close("beat-type") + close("time")
    }
    
    static func clefToMusicXML(_ clef: String) -> String {
        var (sign, line): (String, String) = ("", "")
        switch clef {
        case "g_clef", "g_clef_8vb":
            sign = "G"
            line = "2"
        case "f_clef":
            sign = "F"
            line = "4"
        case "c_clef":
            sign = "C"
            line = "4"
        default:
            break
        }
        
        return openNewline("clef") + open("sign") + sign + close("sign") + open("line") + line + close("line") + close("clef")
    }
    
    static func noteToMusicXML(_ note: ScoreNote, beam: String? = nil, stem: String? = nil) -> String {
        var xml = openNewline("note")
        var accidental: String = ""
        if note.step == "rest" {
            xml += autoClose("rest")
        } else {
            xml += openNewline("pitch") + open("step") + note.step + close("step")
            if note.accidental == "sharp" {
                xml += open("alter") + "1" + close("alter")
                accidental = open("accidental") + "sharp" + close("accidental")
            } else if note.accidental == "flat" {
                xml += open("alter") + "-1" + close("alter")
                accidental = open("accidental") + "flat" + close("accidental")
            }
            xml += open("octave") + "\(note.octave)" + close("octave") + close("pitch")
        }
        
        xml += open("duration") + "\(Int(note.duration * divisions))" + close("duration")
        xml += open("type") + note.type + close("type")
        xml += note.hasDot ? autoClose("dot") : ""
        
        xml += accidental
        
        if let stem = stem {
            xml += open("stem") + stem + close("stem")
        }
        
        if let beam = beam {
            let numberOfBeams = Int(1 / (2 * note.duration))
            for number in 1...numberOfBeams {
                xml += "<beam number=\"\(number)\">" + beam + close("beam")
            }
        }
        
        xml += close("note")
        return xml
    }
    
    static func systemToMusicXML(_ system: ScoreSystem) -> String {
        var xml: String = ""
        
        let beatsInMeasure: Float = Float(String(system.time.characters.first!))!
        var firstNote: Bool = true
        var firstNoteInMeasure: Bool = true
        var cumDuration: Float = 0
        var measureIndex: Int = 1
        
        var eighthStreak: Int = 0
        var sixteenthStreak: Int = 0
        var prevStem: String = "up"
        
        for (index, note) in system.notes.enumerated() {
            var note = note
            if cumDuration + note.duration > beatsInMeasure {
                note.duration = beatsInMeasure - cumDuration
            }
            cumDuration += note.duration
            
            if firstNoteInMeasure {
                let openMeasure = "<measure number=\"\(measureIndex)\">\n"
                xml += (firstNote ? "" : close("measure")) + openMeasure
                if (measureIndex - 1) % 4 == 0 {
                    xml += "<print new-system=\"yes\">" + close("print")
                }
                firstNoteInMeasure = false
            }
            
            if firstNote {
                var attributes = openNewline("attributes")
                attributes += open("divisions") + "\(Int(divisions))" + close("divisions")
                attributes += timeToMusicXML(system.time)
                attributes += clefToMusicXML(system.clef)
                attributes += close("attributes")
                xml += attributes
                firstNote = false
            }
            
            var beam: String?
            let nextNote: ScoreNote
            if index < system.notes.count - 1 {
                nextNote = system.notes[index + 1]
            } else {
                nextNote = ScoreNote(step: "", accidental: "", octave: -1, duration: -1)
            }
            
            let prevNote: ScoreNote = index > 0 ? system.notes[index - 1] : ScoreNote(step: "", accidental: "", octave: -1, duration: -1)
            let lastNoteInMeasure = nextNote.duration + cumDuration > beatsInMeasure
            let lastNoteInPiece: Bool = index == system.notes.count - 1
            
            if note.isEighth {
                if (note.duration == nextNote.duration) {
                    if lastNoteInMeasure {
                        beam = "end"
                        eighthStreak = 0
                    } else if eighthStreak == 0 && !prevNote.hasDot {
                        beam = "begin"
                        eighthStreak += 1
                    } else if eighthStreak == 3 {
                        beam = "end"
                        eighthStreak = 0
                    } else {
                        beam = "continue"
                        eighthStreak += 1
                    }
                } else if lastNoteInPiece && note.duration == prevNote.duration {
                    beam = "end"
                    eighthStreak = 0
                } else {
                    if eighthStreak != 0 {
                        beam = "end"
                        eighthStreak = 0
                    }
                }
            }
            
            if note.isSixteenth {
                if (note.duration == nextNote.duration) {
                    if lastNoteInMeasure {
                        beam = "end"
                        sixteenthStreak = 0
                    } else if sixteenthStreak == 0 && !prevNote.hasDot {
                        beam = "begin"
                        sixteenthStreak += 1
                    } else if sixteenthStreak == 3 {
                        beam = "end"
                        sixteenthStreak = 0
                    } else {
                        beam = "continue"
                        sixteenthStreak += 1
                    }
                } else if lastNoteInPiece && note.duration == prevNote.duration {
                    beam = "end"
                    sixteenthStreak = 0
                } else {
                    if sixteenthStreak != 0 {
                        beam = "end"
                        sixteenthStreak = 0
                    }
                }
            }
            
            var stem: String = note.octave > 4 ? "down" : "up"
            if beam == "continue" || beam == "end" {
                stem = prevStem
            }
            
            xml += noteToMusicXML(note, beam: beam, stem: stem)
            prevStem = stem
            
            if cumDuration == beatsInMeasure {
                cumDuration = 0
                measureIndex += 1
                firstNoteInMeasure = true
            }
        }
        
        xml += "<barline location = \"right\">\n" + open("bar-style") + "light-heavy" + close("bar-style") + close("barline")
        xml += close("measure")
        
        return xml
    }
    
    static func toMusicXML(_ score: ScoreSystem) -> String {
        var xml: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += openNewline("score-partwise")
        
        xml += openNewline("part-list")
        xml += "<score-part id=\"P1\">\n" + open("part-name") + "Piano" + close("part-name") + close("score-part")
        xml += close("part-list")
        
        xml += "<part id=\"P1\">\n"
        xml += systemToMusicXML(score)
        xml += close("part")
        
        xml += close("score-partwise")
        return xml
    }
}
