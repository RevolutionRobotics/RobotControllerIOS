//
//  FirmwareUpdate.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct FirmwareUpdate: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let filename = "filename"
        static let url = "url"
    }

    // MARK: - Path
    static var firebasePath: String = "firmware"

    // MARK: - Properties
    var fileName: String
    var url: String

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let fileName = dictionary[Constants.filename] as? String,
            let url = dictionary[Constants.url] as? String else {
                return nil
        }

        self.fileName = fileName
        self.url = url
    }
}
