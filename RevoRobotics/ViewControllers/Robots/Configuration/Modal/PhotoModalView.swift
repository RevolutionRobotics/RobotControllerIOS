//
//  PhotoModalView.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PhotoModalView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var robotImageView: UIImageView!
    @IBOutlet private weak var deleteButton: RRButton!
    @IBOutlet private weak var takeNewButton: RRButton!
    @IBOutlet private weak var imagePlaceholderView: UIView!

    // MARK: - Callbacks
    var showImagePicker: Callback?
    var deleteHandler: Callback?

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        setupButtons()
        setupTitle()
        setupImagePlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        takeNewButton.setBorder(strokeColor: .white, croppedCorners: [.topRight])
        deleteButton.setBorder(fillColor: .clear, strokeColor: .clear, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Setups
extension PhotoModalView {
    private func setupButtons() {
        deleteButton.setTitle(ModalKeys.Camera.delete.translate(), for: .normal)
        takeNewButton.setTitle(ModalKeys.Camera.newPhoto.translate(), for: .normal)
    }

    private func setupTitle() {
        titleLabel.text = ModalKeys.Camera.title.translate()
    }

    private func setupImagePlaceholder() {
        imagePlaceholderView.layer.borderWidth = 1
        imagePlaceholderView.layer.borderColor = Color.white40.cgColor
    }
}

// MARK: - Actions
extension PhotoModalView {
    func setImage(_ image: UIImage?) {
        robotImageView.image = image
    }

    @IBAction private func takeNewPhoto(_ sender: Any) {
        showImagePicker?()
    }

    @IBAction private func deleteCurrent(_ sender: Any) {
        robotImageView.image = nil
        deleteHandler?()
    }
}
