//
//  UIColor+HEX.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        guard hex.hasPrefix("#") else { return nil }

        let red, green, blue: CGFloat
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt32 = 0

            if scanner.scanHexInt32(&hexNumber) {
                red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                blue = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                self.init(red: red, green: green, blue: blue, alpha: 1.0)
                return
            }
        }

        return nil
    }
}
