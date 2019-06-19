//
//  ButtonControllerAssignmentItemJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class ButtonControllerAssignmentItemJSONData: JSONRepresentable {
    // MARK: - Properties
    let id: Int
    let priority: Int

    // MARK: - Initialization
    init(id: Int, priority: Int) {
        self.id = id
        self.priority = priority
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case id
        case priority
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: CodingKeys.id)
        try container.encode(priority, forKey: CodingKeys.priority)
    }
}
