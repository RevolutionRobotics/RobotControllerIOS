//
//  ChallengeDetailContentProtocol.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 28..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol ChallengeDetailContentProtocol: UIView {
    func setup(with step: ChallengeStep, challengeId: String)
}
