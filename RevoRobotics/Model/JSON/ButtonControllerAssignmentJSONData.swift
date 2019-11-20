//
//  ButtonControllerAssignmentJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class ButtonControllerAssignmentJSONData: JSONRepresentable {
    // MARK: - Properties
    let buttons: [ButtonControllerAssignmentItemJSONData]

    // MARK: - Initialization
    init(id: Int, priority: Int) {
        self.buttons = [ButtonControllerAssignmentItemJSONData(id: id, priority: priority)]
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case buttons
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(buttons, forKey: CodingKeys.buttons)
    }
}
