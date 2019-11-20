//
//  SideButton.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class SideButton: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    // MARK: - Properties
    var selectionHandler: Callback?
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
}

// MARK: - View lifecycle
extension SideButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.setBorder(fillColor: .black, strokeColor: .clear, croppedCorners: [.bottomLeft])
        setBorder(strokeColor: Color.brownishGrey, croppedCorners: [.bottomLeft])
    }
}

// MARK: - Actions
extension SideButton {
    @IBAction private func buttonTapped(_ sender: Any) {
        selectionHandler?()
    }
}
