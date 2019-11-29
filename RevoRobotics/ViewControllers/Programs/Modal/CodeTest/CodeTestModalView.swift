//
//  CodeTestModalView.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 11. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class CodeTestModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var stopButton: RRButton!
    @IBOutlet private weak var testStatusLabel: UILabel!

    // MARK: - Properties
    var stopPressedCallback: Callback?
}

// MARK: - View lifecycle
extension CodeTestModalView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
    }
}

// MARK: - Public methods
extension CodeTestModalView {
    func updateLabel(isRunning running: Bool) {
        let status = running
            ? ProgramsKeys.Main.testRunning
            : ProgramsKeys.Main.testUploading

        testStatusLabel.text = status.translate().uppercased()
    }
}

// MARK: - Private methods
extension CodeTestModalView {
    private func setupLabels() {
        testStatusLabel.text = ProgramsKeys.Main.testUploading.translate().uppercased()
        stopButton.setTitle(ProgramsKeys.Main.testStop.translate(), for: .normal)
        stopButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.bottomLeft, .topRight])
    }
}

// MARK: - Actions
extension CodeTestModalView {
    @IBAction private func stopButtonPressed(_ sender: Any) {
        stopPressedCallback?()
    }
}
