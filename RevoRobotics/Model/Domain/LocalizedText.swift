//
//  LocalizedText.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct LocalizedText: Decodable, Equatable {
    // MARK: - Constants
    private enum Constants {
        static let en = "en"
    }

    // MARK: - Properties
    var en: String
    var text: String {
        return en
    }
}
