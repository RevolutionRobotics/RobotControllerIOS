//
//  BackgroundControllerAssignmentJSONData.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class BackgroundControllerAssignmentJSONData: JSONRepresentable {
    // MARK: - Properties
    let background: Int

    // MARK: - Initialization
    init(priority: Int) {
        self.background = priority
    }

    // MARK: - Encodable
    enum CodingKeys: String, CodingKey {
        case background
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(background, forKey: CodingKeys.background)
    }
}
