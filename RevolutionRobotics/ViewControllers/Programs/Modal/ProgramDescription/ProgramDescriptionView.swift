//
//  ProgramDescriptionView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramDescriptionView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var loadButton: RRButton!
    @IBOutlet private weak var deleteButton: RRButton!

    // MARK: - Variables
    var loadCallback: Callback?
    var deleteCallback: Callback?
}

// MARK: - View lifecycle
extension ProgramDescriptionView {
    override func awakeFromNib() {
        super.awakeFromNib()

        deleteButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        deleteButton.setTitle(ProgramsKeys.SelectProgram.delete.translate(), for: .normal)
        loadButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        loadButton.setTitle(ProgramsKeys.SelectProgram.load.translate(), for: .normal)
    }
}

// MARK: - Setup
extension ProgramDescriptionView {
    func setup(with program: ProgramDataModel) {
        titleLabel.text = program.name
        descriptionLabel.text = program.customDescription
        lastModifiedLabel.text = DateFormatter.string(from: program.lastModified, format: .yearMonthDay)
    }
}

// MARK: - Action handlers
extension ProgramDescriptionView {
    @IBAction private func loadButtonTapped(_ sender: Any) {
        loadCallback?()
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteCallback?()
    }
}
