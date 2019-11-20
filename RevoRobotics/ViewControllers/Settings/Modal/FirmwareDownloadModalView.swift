//
//  FirmwareDownloadModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class FirmwareDownloadModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var downloadingLabel: UILabel!
    @IBOutlet private weak var pleaseWaitLabel: UILabel!
}

// MARK: - View lifecycle
extension FirmwareDownloadModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        downloadingLabel.text = ModalKeys.FirmwareUpdate.downloading.translate().uppercased()
        pleaseWaitLabel.text = ModalKeys.FirmwareUpdate.pleaseWait.translate().uppercased()
    }
}
