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
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!

    // MARK: - Properties
    var deleteCallback: Callback?
    var editCallback: Callback?
    var infoCallback: Callback?
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseDescriptionFontSize: CGFloat = 0
    private var baseLastModifiedFontSize: CGFloat = 0
    private var baseSelectedFontSize: CGFloat = 0
    private var isNewControllerCard: Bool = false

    override var isCentered: Bool {
        didSet {
            selectedView.isHidden = !isCentered || isNewControllerCard
            setState()
        }
    }

    var isControllerSelected: Bool = false {
        didSet {
            setState()
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
    func setup(with controller: ControllerDataModel) {
        isNewControllerCard = controller.type == ControllerType.new.rawValue

        nameLabel.text = isNewControllerCard ? ControllerType.new.displayName() : controller.name
        controllerImageView.image = ControllerType(rawValue: controller.type)?.image()

        guard isNewControllerCard else {
            return
        }

        NSLayoutConstraint.activate([
            controllerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}

// MARK: - Actions
extension ControllerCollectionViewCell {
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        deleteCallback?()
    }

    @IBAction private func modifyButtonTapped(_ sender: Any) {
        editCallback?()
    }

    @IBAction private func infoButtonTapped(_ sender: Any) {
        infoCallback?()
    }
}

// MARK: - Private methods
extension ControllerCollectionViewCell {
    private func setState() {
        let buttonsEnabled = isCentered && !isNewControllerCard

        infoButton.isUserInteractionEnabled = buttonsEnabled
        deleteButton.isUserInteractionEnabled = buttonsEnabled
        modifyButton.isUserInteractionEnabled = buttonsEnabled

        if isNewControllerCard {
            selectedLabel.text = ControllerKeys.create.translate()
            backgroundImageView.image = isCentered ? Image.BuildRobot.cellRedBorder : Image.BuildRobot.cellWhiteBorder
            return
        } else if isControllerSelected {
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
}
