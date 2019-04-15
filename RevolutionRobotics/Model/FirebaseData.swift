//
//  FirebaseData.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseData {
    // MARK: - Initialization
    init?(snapshot: DataSnapshot)
}
