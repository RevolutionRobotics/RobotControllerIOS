//
//  Port.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

protocol Port {
    var variableName: String { get set }
    var type: String { get set }
    var testCodeId: Int { get set }
}
