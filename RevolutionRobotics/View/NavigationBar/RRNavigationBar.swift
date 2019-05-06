//
//  RRNavigationBar.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol RRNavigationBarDelegate: class {
    func backButtonDidTap()
    func popToRootViewController(animated: Bool)
}

final class RRNavigationBar: RRCustomView {
    // MARK: - Outlets
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Delegate
    private weak var delegate: RRNavigationBarDelegate? = nil {
        didSet {
            backButton.isHidden = delegate == nil
        }
    }
}

// MARK: - Setup
extension RRNavigationBar {
    func setup(title: String? = nil, delegate: RRNavigationBarDelegate? = nil) {
        titleLabel.text = title
        self.delegate = delegate
    }
}

// MARK: - Actions
extension RRNavigationBar {
    @IBAction private func backButtonTapped(_ sender: Any) {
        delegate?.backButtonDidTap()
    }
}
