//
//  ModalViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func backgroundTapped()
    func dismissModalViewController()
}

final class ModalViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var modalContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!

    // MARK: - Properties
    weak var delegate: ModalViewControllerDelegate?

    var contentView: UIView?
    var isCloseHidden: Bool = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
}

// MARK: - View lifecycle
extension ModalViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalContainer.setBorder(strokeColor: Color.blackTwo)

        guard let content = contentView else { return }
        modalContainer.addSubview(content)
        content.anchorToSuperview()
        closeButton.isHidden = isCloseHidden
    }
}

// MARK: - Actions
extension ModalViewController {
    @IBAction private func closeButtonTapped(_ sender: Any) {
        delegate?.backgroundTapped()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        delegate?.backgroundTapped()
    }
}
