//
//  UpdatingFirmwareModalView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

final class UpdatingFirmwareModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
}

// MARK: - View lifecycle
extension UpdatingFirmwareModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        activityIndicator.startAnimating()
        titleLabel.text = ModalKeys.FirmwareUpdate.firmwareDownloadInfo.translate().uppercased()
        subtitleLabel.text = ModalKeys.FirmwareUpdate.firmwareDownloadPleaseWait.translate().uppercased()
    }
}
