//
//  ZipDownloadView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 05..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

final class ZipDownloadView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var messageView: UILabel!

    func setup(with title: String, message: String) {
        titleView.text = title
        messageView.text = message
    }
}
