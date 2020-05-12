//
//  ChallengeDetailZoomableContent.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengeDetailZoomableContent: ChallengeStepView {
    // MARK: - Outlets
    @IBOutlet private weak var zoomableImageView: RRZoomableImageView!
}

// MARK: - ChallengeDetailContent
extension ChallengeDetailZoomableContent: ChallengeDetailContentProtocol {
    func setup(with step: ChallengeStep, challengeId: String) {
        zoomableImageView.frame = bounds
        zoomableImageView.resizeImageView()
        setupImage(for: step, in: zoomableImageView.imageView, challengeId: challengeId)
    }
}
