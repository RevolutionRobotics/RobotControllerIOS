//
//  Font.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum Font {
    static func jura(size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "Jura-Regular", size: size)!
        case .bold:
            return UIFont(name: "Jura-Bold", size: size)!
        default:
            return UIFont(name: "Jura-Bold", size: size)!
        }
    }

    static func barlow(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "Barlow-Regular", size: size)!
        case .medium:
            return UIFont(name: "Barlow-Medium", size: size)!
        case .bold:
            return UIFont(name: "Barlow-Bold", size: size)!
        default:
            return UIFont(name: "Barlow-Regular", size: size)!
        }
    }
}
