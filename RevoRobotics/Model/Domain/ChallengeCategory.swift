//
//  ChallengeCategory.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct ChallengeCategory: Decodable, FirebaseOrderable {
    let id: String
    let name: LocalizedText
    let image: String
    let description: LocalizedText
    let challenges: [String: Challenge]
    var order: Int
}
