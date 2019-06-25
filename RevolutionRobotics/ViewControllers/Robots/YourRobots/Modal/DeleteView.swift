//
//  DeleteView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 08..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class DeleteView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var deleteIconImageView: UIImageView!
    @IBOutlet private weak var cancelButton: RRButton!
    @IBOutlet private weak var deleteButton: RRButton!

    // MARK: - Properties
    var cancelButtonHandler: Callback?
    var deleteButtonHandler: Callback?

    var title: String? {
        didSet {
            titleLabel.text = title?.uppercased()
        }
    }
}

// MARK: - View lifecycle
extension DeleteView {
    override func awakeFromNib() {
        super.awakeFromNib()

        cancelButton.setBorder(fillColor: .clear,
                               strokeColor: Color.blackTwo,
                               croppedCorners: [.bottomLeft])
        deleteButton.setBorder(fillColor: .clear,
                               strokeColor: UIColor.white,
                               croppedCorners: [.topRight])
        cancelButton.setTitle(ModalKeys.DeleteRobot.cancel.translate(), for: .normal)
        deleteButton.setTitle(ModalKeys.DeleteRobot.confirm.translate(), for: .normal)
    }
}

// MARK: - Actions
extension DeleteView {
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        cancelButtonHandler?()
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteButtonHandler?()
    }
}
