//
//  DeleteRobotView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 08..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DeleteRobotView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deleteIconImageView: UIImageView!
    @IBOutlet private weak var cancelButton: RRButton!
    @IBOutlet private weak var deleteButton: RRButton!

    // MARK: - Properties
    var cancelButtonHandler: Callback?
    var deleteButtonHandler: Callback?
}

// MARK: - View lifecycle
extension DeleteRobotView {
    override func awakeFromNib() {
        super.awakeFromNib()

        cancelButton.setBorder(fillColor: Color.black26,
                               strokeColor: Color.blackTwo,
                               croppedCorners: [.bottomLeft])
        deleteButton.setBorder(fillColor: Color.blackTwo,
                               strokeColor: UIColor.white,
                               croppedCorners: [.topRight])
        titleLabel.text = ModalKeys.DeleteRobot.description.translate().uppercased()
        cancelButton.setTitle(ModalKeys.DeleteRobot.cancel.translate(), for: .normal)
        deleteButton.setTitle(ModalKeys.DeleteRobot.confirm.translate(), for: .normal)
    }
}

// MARK: - Actions
extension DeleteRobotView {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        cancelButtonHandler?()
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteButtonHandler?()
    }
}
