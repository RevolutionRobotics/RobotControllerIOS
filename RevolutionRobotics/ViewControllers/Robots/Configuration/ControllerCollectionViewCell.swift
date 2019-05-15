//
//  ControllerCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ControllerCollectionViewCell: ResizableCell {
    // MARK: - Constants
    private enum Constants {
        static let dateFormat = "YYYY/MM/dd"
    }

    // MARK: - Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var controllerImageView: UIImageView!
    @IBOutlet private weak var lastModifiedLabel: UILabel!
    @IBOutlet private weak var infoButton: RRButton!
    @IBOutlet private weak var deleteButton: RRButton!
    @IBOutlet private weak var modifyButton: RRButton!
    @IBOutlet private weak var selectedLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var selectedView: UIView!

    // MARK: - Constraints
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!

    // MARK: - Callbacks
    var deleteCallback: Callback?
    var modifyCallback: Callback?
    var infoCallback: Callback?

    // MARK: - Variables
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseDescriptionFontSize: CGFloat = 0
    private var baseLastModifiedFontSize: CGFloat = 0
    private var baseSelectedFontSize: CGFloat = 0

    override var isCentered: Bool {
        didSet {
            selectedView.isHidden = !isCentered
            setState()
        }
    }

    override var isSelected: Bool {
        didSet {
            setState()
        }
    }

    // MARK: - Functions
    private func setState() {
        infoButton.isUserInteractionEnabled = isCentered
        deleteButton.isUserInteractionEnabled = isCentered
        modifyButton.isUserInteractionEnabled = isCentered
        if isSelected {
            selectedLabel.text = RobotsKeys.Controllers.controllerSelected.translate()
            backgroundImageView.image =
                isCentered ? Image.Configuration.Controllers.cellRedBorderSelected :
                Image.Configuration.Controllers.cellWhiteBorderSelected
        } else {
            selectedLabel.text = RobotsKeys.Controllers.controllerChooseThis.translate()
            backgroundImageView.image =
                isCentered ? Image.Configuration.Controllers.cellRedBorderNonSelected :
                Image.Configuration.Controllers.cellWhiteBorderNonSelected
        }
    }

    override func set(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
        nameLabel.font = nameLabel.font.withSize(baseNameFontSize * multiplier * multiplier)
        lastModifiedLabel.font = lastModifiedLabel.font.withSize(baseLastModifiedFontSize * multiplier * multiplier)
        selectedLabel.font = selectedLabel.font.withSize(baseSelectedFontSize * multiplier * multiplier)
    }
}

// MARK: - View lifecycle
extension ControllerCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        baseHeightMultiplier = baseHeight.multiplier
        baseWidthMultiplier = baseWidth.multiplier
        baseNameFontSize = nameLabel.font.pointSize
        baseLastModifiedFontSize = lastModifiedLabel.font.pointSize
        baseSelectedFontSize = selectedLabel.font.pointSize
    }
}

// MARK: - Setup
extension ControllerCollectionViewCell {
    func setup(with controller: Controller) {
        nameLabel.text = controller.name
        controllerImageView.image = controller.type.image
        lastModifiedLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: controller.lastModified))
    }
}

// MARK: - Event handlers
extension ControllerCollectionViewCell {
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteCallback?()
    }

    @IBAction private func modifyButtonTapped(_ sender: Any) {
        modifyCallback?()
    }

    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoCallback?()
    }
}
