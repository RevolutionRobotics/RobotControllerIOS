//
//  ModalViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func dismissViewController()
}

final class ModalViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var modalContainer: UIView!

    // MARK: - Delegate
    weak var delegate: ModalViewControllerDelegate?

    // MARK: - Content
    var contentView: UIView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalContainer.crop(strokeColor: Color.darkGrey)

        guard let content = contentView else { return }
        modalContainer.addSubview(content)
        content.anchorToSuperview()
    }
}

// MARK: - Actions
extension ModalViewController {
    @IBAction private func closeButtonTapped(_ sender: Any) {
        delegate?.dismissViewController()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        delegate?.dismissViewController()
    }
}
