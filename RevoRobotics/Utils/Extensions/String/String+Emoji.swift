//
//  String+Emoji.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import CoreText

extension String {
    var isEmoji: Bool {
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        let glyphCount = CTLineGetGlyphCount(line)

        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            0x1F1E6...0x1F1FF: // Flags
                return glyphCount == 1
            default:
                continue
            }
        }
        return false
    }
}
