//
//  ResizableCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 02..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class ResizableCell: UICollectionViewCell {
    // MARK: - Constants
    private enum Constants {
        static let dateFormat = "YYYY/MM/dd"
    }

    // MARK: - Variables
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        return dateFormatter
    }

    var isCentered: Bool = false
    var indexPath: IndexPath?
    @objc dynamic func set(multiplier: CGFloat) { }
}
