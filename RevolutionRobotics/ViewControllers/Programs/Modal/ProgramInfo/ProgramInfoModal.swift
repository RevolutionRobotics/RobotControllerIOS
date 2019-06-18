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
        case incompatible
        case info
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var editProgramButton: RRButton!
    @IBOutlet private weak var actionButton: RRButton!
    @IBOutlet private weak var issueLabel: UILabel!

    // MARK: - Private
    private var editButtonTapped: Callback?
    private var actionButtonTapped: CallbackType<InfoType>?
    private var type: InfoType = .add {
        didSet {
            updateActionButton()
        }
    }
}

// MARK: - Config
extension ProgramInfoModal {
    func configure(
        program: ProgramDataModel,
        infoType: InfoType,
        issue: String?,
        editButtonHandler: Callback?,
        actionButtonHandler: CallbackType<InfoType>?) {
        type = infoType
        editButtonTapped = editButtonHandler
        actionButtonTapped = actionButtonHandler
        titleLabel.text = program.name
        descriptionLabel.text = program.customDescription
        dateLabel.text = DateFormatter.string(from: program.lastModified, format: .yearMonthDay)
        issueLabel.text = issue
    }

    private func updateActionButton() {
        switch type {
        case .add:
            actionButton.setImage(Image.Common.plusIcon, for: .normal)
            actionButton.setTitle(ModalKeys.Program.addProgram.translate(), for: .normal)
            editProgramButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
            actionButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        case .remove:
            actionButton.setImage(Image.Common.closeIcon, for: .normal)
            actionButton.setTitle(ModalKeys.Program.removeProgram.translate(), for: .normal)
            editProgramButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
            actionButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        case .incompatible:
            actionButton.setImage(Image.tickIcon, for: .normal)
            actionButton.setTitle(ModalKeys.Program.gotIt.translate(), for: .normal)
            issueLabel.isHidden = false
            editProgramButton.setBorder(fillColor: Color.black26, croppedCorners: [.bottomLeft])
            actionButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        case .info:
            editProgramButton.removeFromSuperview()
            setNeedsLayout()
            layoutIfNeeded()
            actionButton.setImage(Image.tickIcon, for: .normal)
            actionButton.setTitle(ModalKeys.Program.gotIt.translate(), for: .normal)
            actionButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight, .bottomLeft])
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
