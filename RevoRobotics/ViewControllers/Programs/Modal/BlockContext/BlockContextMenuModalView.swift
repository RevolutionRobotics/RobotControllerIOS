//
//  BlockContextMenuModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class BlockContextMenuModalView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var noteInputField: RRInputField!
    @IBOutlet private weak var deleteButton: RRButton!
    @IBOutlet private weak var helpButton: RRButton!
    @IBOutlet private weak var duplicateButton: RRButton!

    // MARK: - Callbacks
    var deleteCallback: Callback?
    var helpCallback: Callback?
    var duplicateCallback: Callback?

    // MARK: - Properties
    var comment: String? {
        guard let text = noteInputField.text else { return nil }
        return text.isEmpty ? nil : text
    }
}

// MARK: - View lifecycle
extension BlockContextMenuModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        deleteButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
        deleteButton.setTitle(ProgramsKeys.BlockContext.delete.translate(), for: .normal)
        helpButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [])
        helpButton.setTitle(ProgramsKeys.BlockContext.help.translate(), for: .normal)
        duplicateButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
        duplicateButton.setTitle(ProgramsKeys.BlockContext.duplicate.translate(), for: .normal)
    }
}

// MARK: - Functions
extension BlockContextMenuModalView {
    func setup(with contextHandler: BlockContextHandler) {
        titleLabel.text = contextHandler.title.uppercased()
        noteInputField.setup(title: ProgramsKeys.BlockContext.title.translate(),
                             placeholder: ProgramsKeys.BlockContext.placeholder.translate(),
                             characterLimit: nil)
        noteInputField.text = contextHandler.comment
    }
}

// MARK: - Action handlers
extension BlockContextMenuModalView {
    @IBAction private func duplicateButtonTapped(_ sender: Any) {
        duplicateCallback?()
    }

    @IBAction private func helpButtonTapped(_ sender: Any) {
        helpCallback?()
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteCallback?()
    }
}
