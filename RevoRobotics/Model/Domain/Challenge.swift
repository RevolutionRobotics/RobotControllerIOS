//
//  Challenge.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Challenge: Decodable, FirebaseOrderable {
    let id: String
    let name: LocalizedText
    let challengeSteps: [String: ChallengeStep]
    var order: Int
}
