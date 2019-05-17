//
//  ProgramInfoModal.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramInfoModal: UIView {
    // MARK: - Type
    enum InfoType {
        case add
        case remove
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var editProgramButton: RRButton!
    @IBOutlet private weak var actionButton: RRButton!

    // MARK: - Private
    private var editButtonTapped: Callback?
    private var actionButtonTapped: CallbackType<InfoType>?
    private var type: InfoType = .add {
        didSet {
            updateActionButton()
        }
    }
}

// MARK: - Lifecycle
extension ProgramInfoModal {
    override func awakeFromNib() {
        super.awakeFromNib()
        editProgramButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
        actionButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Config
extension ProgramInfoModal {
    func configure(
        program: Program,
        infoType: InfoType,
        editButtonHandler: Callback?,
        actionButtonHandler: CallbackType<InfoType>?
    ) {
        type = infoType
        editButtonTapped = editButtonHandler
        actionButtonTapped = actionButtonHandler
        titleLabel.text = program.name
        descriptionLabel.text = program.description
        dateLabel.text = "\(program.lastModified)"
    }

    private func updateActionButton() {
        switch type {
        case .add:
            actionButton.setImage(Image.Common.plusIcon, for: .normal)
            actionButton.setTitle("Add Program", for: .normal)
        case .remove:
            actionButton.setImage(Image.Common.closeIcon, for: .normal)
            actionButton.setTitle("Remove Program", for: .normal)
        }
    }
}

// MARK: - Actions
extension ProgramInfoModal {
    @IBAction private func editButtonTapped(_ sender: Any) {
        editButtonTapped?()
    }

    @IBAction private func actionButtonTapped(_ sender: Any) {
        actionButtonTapped?(type)
    }
}
