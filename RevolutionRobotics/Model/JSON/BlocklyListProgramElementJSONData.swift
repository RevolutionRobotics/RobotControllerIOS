//
//  BlocklyListProgramElementJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class BlocklyListProgramElementJSONData: JSONRepresentable {
    // MARK: - Properties
    let pythoncode: String
    let assignments: JSONRepresentable

    // MARK: - Initialization
    init(code: String, isButton: Bool, priority: Int, buttonId: Int? = nil) {
        self.pythoncode = code
        if isButton {
            self.assignments = ButtonControllerAssignmentJSONData(id: buttonId!, priority: priority)
        } else {
            self.assignments = BackgroundControllerAssignmentJSONData(priority: priority)
        }
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case pythoncode
        case assignments
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pythoncode, forKey: CodingKeys.pythoncode)
        try container.encode(assignments, forKey: CodingKeys.assignments)
    }
}
