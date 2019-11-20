//
//  String+Replace.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 08. 21..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension String {
    func replacingPattern(regexPattern: String, with string: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern,
                                                options: NSRegularExpression.Options.caseInsensitive)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: string)
        } catch {
            return self
        }
    }
}
