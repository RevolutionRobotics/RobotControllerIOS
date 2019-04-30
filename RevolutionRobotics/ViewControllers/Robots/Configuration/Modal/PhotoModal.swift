//
//  PhotoModal.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PhotoModal: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var robotImageView: UIImageView!
    @IBOutlet private weak var deleteButton: RRButton!
    @IBOutlet private weak var takeNewButton: RRButton!

    // MARK: - Callbacks
    var showImagePicker: Callback?
    var deleteHandler: Callback?

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButtons()
    }
}

// MARK: - Setups
extension PhotoModal {
    private func setupButtons() {
        deleteButton.setTitle("Delete", for: .normal)
        takeNewButton.setTitle("Take new photo", for: .normal)
    }

    private func setupTitle() {
        titleLabel.text = "ROBOTS PROFIL'S PICTURE"
    }
}

// MARK: - Actions
extension PhotoModal {
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
