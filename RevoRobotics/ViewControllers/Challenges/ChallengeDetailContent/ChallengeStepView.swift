//
//  ChallengeStepView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 05. 12..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

class ChallengeStepView: UIView {
    func setupImage(for step: ChallengeStep, in imageView: UIImageView, challengeId: String) {
        guard
            let currentFile = URL(string: step.image)?.pathComponents.last,
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            imageView.downloadImage(from: step.image)
            return
        }

        let stepImageUrl = documentsDirectory
            .appendingPathComponent(ZipType.challenges.rawValue, isDirectory: true)
            .appendingPathComponent(challengeId, isDirectory: true)
            .appendingPathComponent(currentFile)

        do {
            let resourceReachable = try stepImageUrl.checkResourceIsReachable()
            guard resourceReachable else {
                imageView.downloadImage(from: step.image)
                return
            }

            imageView.image = UIImage(contentsOfFile: stepImageUrl.path)
        } catch let error {
            error.report()
            imageView.downloadImage(from: step.image)
        }
    }
}
