//
//  String+Base64.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension String {
    var base64Encoded: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }

    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
