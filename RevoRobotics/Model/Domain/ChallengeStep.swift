//
//  ChallengeStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct ChallengeStep: Decodable {
    let id: String
    let title: LocalizedText
    let text: LocalizedText
    let image: String
    let parts: [Part]?
    let type: ChallengeType
    let buttonText: LocalizedText?
    let buttonUrl: String?
}
