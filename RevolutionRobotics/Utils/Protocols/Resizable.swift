//
//  Resizable.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol Resizable {
    var isCentered: Bool { get set }
    var indexPath: IndexPath? { get set }
    func setSize(multiplier: CGFloat)
}
