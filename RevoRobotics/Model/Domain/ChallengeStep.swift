//
//  ChallengeStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct ChallengeStep: Decodable, FirebaseOrderable {
    let id: String
    let title: LocalizedText
    let description: LocalizedText
    let image: String
    let parts: [String: Part]?
    let challengeType: ChallengeType
    let buttonText: LocalizedText?
    let buttonUrl: String?
    var order: Int
}
