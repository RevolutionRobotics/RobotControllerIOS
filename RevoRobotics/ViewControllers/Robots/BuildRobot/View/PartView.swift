//
//  PartView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 23..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PartView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var partImageView: UIImageView!
    @IBOutlet private weak var separatorView: UIView!

    // MARK: - Properties
    var isLast: Bool = false {
        didSet {
            separatorView.isHidden = isLast
        }
    }
}

// MARK: - Setups
extension PartView {
    func setup(with urlString: String?) {
        guard let urlString = urlString else {
            partImageView.image = nil
            return
        }
        isHidden = false
        partImageView.image = nil
        partImageView.downloadImage(googleStorageURL: urlString)
    }
}
