//
//  LocalizedText.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 07. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct LocalizedText: Equatable {
    // MARK: - Constants
    private enum Constants {
        static let en = "en"
    }

    // MARK: - Properties
    var en: String

    var text: String {
        return en
    }

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let en = dictionary[Constants.en] as? String else {
                return nil
        }

        self.en = en
    }
}
