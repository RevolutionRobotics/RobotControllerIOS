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

    // MARK: - Constants
    private enum Constants {
        static let keyboardTopSpace: CGFloat = 20
    }

    // MARK: - Properties
    weak var delegate: ModalViewControllerDelegate?

    var contentView: UIView?
    var isCloseHidden: Bool = false

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    deinit {
        unregisterObserver()
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
        registerObserver()
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

// MARK: - Keyboard
extension ModalViewController {
    private func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func unregisterObserver() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let view = view.allSubviews().first(where: { $0.isFirstResponder }) else {
            return
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let frame = view.superview?.convert(view.frame, to: nil)
        self.view.frame.origin.y = min(0, keyboardHeight - (frame!.maxY + Constants.keyboardTopSpace))
    }

    @objc private func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
