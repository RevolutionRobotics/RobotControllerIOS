//
//  DateFormatter.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

extension DateFormatter {
    enum Format: String {
        case yearMonthDay = "yyyy-MMM-dd"
    }

    static func string(from date: Date?, format: Format) -> String {
        guard let date = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: date).uppercased()
    }
}
