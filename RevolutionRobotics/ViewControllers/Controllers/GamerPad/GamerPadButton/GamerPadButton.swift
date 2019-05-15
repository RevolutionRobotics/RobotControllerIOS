//
//  GamerPadButton.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class GamerPadButton: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!

    // MARK: - Callback
    private var buttonTapped: CallbackType<Bool>?
    private var pressed = false {
        didSet {
            buttonTapped?(pressed)
        }
    }
}

// MARK: - Setup
extension GamerPadButton {
    func setup(title: String, callback: CallbackType<Bool>?) {
        buttonTapped = callback
        label.text = title
        button.setBackgroundColor(Color.brightRed, for: .normal)
        button.setBackgroundColor(Color.brightRed.withAlphaComponent(0.9), for: .highlighted)
        button.roundToCircle()
    }
}

// MARK: - Actions
extension GamerPadButton {
    @IBAction private func buttonTapped(_ sender: Any) {
        pressed.toggle()
    }
}
