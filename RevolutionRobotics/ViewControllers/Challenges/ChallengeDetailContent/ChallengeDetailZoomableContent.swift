//
//  ChallengeDetailZoomableContent.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailZoomableContent: ChallengeDetailContentView {
    // MARK: - Outlets
    @IBOutlet private weak var zoomableImageView: RRZoomableImageView!

    // MARK: - Setup
    override func setup(with step: ChallengeStep) {
        zoomableImageView.imageView.downloadImage(googleStorageURL: step.image)
    }
}
