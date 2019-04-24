//
//  BaseViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    init() {
        super.init(nibName: type(of: self).nibName, bundle: Bundle(for: type(of: self)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - RRNavigationBarDelegate
extension BaseViewController: RRNavigationBarDelegate {
    func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Modal
extension BaseViewController {
    func presentModal(with contentView: UIView, animated: Bool = true) {
        let modalViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        modalViewController.modalPresentationStyle = .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.delegate = self
        modalViewController.contentView = contentView
        present(modalViewController, animated: animated)
    }
}

// MARK: - ModalViewControllerDelegate
extension BaseViewController: ModalViewControllerDelegate {
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
