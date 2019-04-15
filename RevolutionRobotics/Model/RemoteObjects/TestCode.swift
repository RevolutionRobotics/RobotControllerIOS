//
//  TestCode.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct TestCode: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let codeUrl = "codeUrl"
    }

    // MARK: - Properties
    var id: Int
    var codeUrl: String

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }
        guard let id = dic[Constants.id] as? Int,
            let codeUrl = dic[Constants.codeUrl] as? String else {
                return nil
        }

        self.id = id
        self.codeUrl = codeUrl
    }
}
