//
//  Milestone.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Milestone: Decodable {
    let image: String
    let testCode: String
    let testDescription: LocalizedText
    let testImage: String
    let type: MilestoneType
}

// MARK: - Equatable
extension Milestone: Equatable {
    static func == (lhs: Milestone, rhs: Milestone) -> Bool {
        return lhs.image == rhs.image && lhs.testCode == rhs.testCode && lhs.type == rhs.type
    }
}
