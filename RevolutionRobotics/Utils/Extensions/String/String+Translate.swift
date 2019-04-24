//
//  String+Translate.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension String {
    public func translate() -> String {
        return self.translate(args: [])
    }

    public func translate(args: CVarArg...) -> String {
        return NSString(format: NSLocalizedString(self, comment: "#"), arguments: getVaList(args)) as String
    }
}
