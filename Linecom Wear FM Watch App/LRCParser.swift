//
//  LRCParser.swift
//  Linecom Wear FM Watch App
//
//  Created by 澪空 on 2024/7/9.
//

import Foundation

struct LRCLine {
    let time: TimeInterval
    let text: String
}

class LRCParser {
    static func parse(_ content: String) -> [LRCLine] {
        let lines = content.components(separatedBy: "\n")
        var lrcLines: [LRCLine] = []

        let timePattern = "\\[(\\d{2}):(\\d{2})\\.(\\d{2})\\]"
        let regex = try! NSRegularExpression(pattern: timePattern, options: [])
        
        for line in lines {
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
            
            for match in matches {
                if match.numberOfRanges == 4,
                   let minuteRange = Range(match.range(at: 1), in: line),
                   let secondRange = Range(match.range(at: 2), in: line),
                   let millisecondRange = Range(match.range(at: 3), in: line) {
                    
                    let minutes = Double(line[minuteRange]) ?? 0
                    let seconds = Double(line[secondRange]) ?? 0
                    let milliseconds = Double(line[millisecondRange]) ?? 0
                    
                    let time = minutes * 60 + seconds + milliseconds / 100
                    let text = String(line[line.index(line.startIndex, offsetBy: match.range(at: 0).length)...]).trimmingCharacters(in: .whitespaces)
                    
                    lrcLines.append(LRCLine(time: time, text: text))
                }
            }
        }
        
        return lrcLines
    }
}
