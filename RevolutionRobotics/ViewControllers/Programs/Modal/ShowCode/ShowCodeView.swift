//
//  ShowCodeView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ShowCodeView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!

    // MARK: - Callbacks
    var doneCallback: Callback?
}

// MARK: - View lifecycle
extension ShowCodeView {
    override func awakeFromNib() {
        super.awakeFromNib()

        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        titleLabel.text = ModalKeys.Program.generatedCodeTitle.translate()
    }
}

// MARK: - Setup
extension ShowCodeView {
    func setup(with code: String) {
        codeLabel.text = code
    }
}

// MARK: - Action handlers
extension ShowCodeView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?()
    }
}
