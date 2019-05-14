//
//  BaseViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu

class BaseViewController: UIViewController {
    // MARK: - Constants
    private enum Constants {
        static let menuFadeStrength: CGFloat = 0.65
        static let menuWidth: CGFloat = UIScreen.main.bounds.width / 3 < 215.0 ? 215.0 : UIScreen.main.bounds.width / 3
        static let communityURL: URL = URL(string: "https://www.google.com")!
    }

    // MARK: - Initialization
    init() {
        super.init(nibName: type(of: self).nibName, bundle: Bundle(for: type(of: self)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - View lifecycle
extension BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSideMenuPreferences()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

// MARK: - RRNavigationBarDelegate
extension BaseViewController: RRNavigationBarDelegate {
    func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }

    func popToRootViewController(animated: Bool) {
        self.dismissViewController()
        navigationController?.popToRootViewController(animated: animated)
    }
}

// MARK: - Modal
extension BaseViewController {
    func presentModal(with contentView: UIView, animated: Bool = true, closeHidden: Bool = false) {
        let modalViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        modalViewController.modalPresentationStyle = .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.delegate = self
        modalViewController.contentView = contentView
        modalViewController.isCloseHidden = closeHidden
        present(modalViewController, animated: animated)
    }

    func presentCommunityModal(presentationFinished: Callback?, url: URL? = nil) {
        dismiss(animated: true, completion: { [weak self] in
            let communityViewController = CommunityViewController(url: url ?? Constants.communityURL)
            communityViewController.presentationFinished = presentationFinished
            communityViewController.modalPresentationStyle = .overFullScreen
            self?.present(communityViewController, animated: true, completion: nil)
        })
    }
}

// MARK: - ModalViewControllerDelegate
extension BaseViewController: ModalViewControllerDelegate {
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Side
extension BaseViewController {
    enum MenuSide {
        case left
        case right
    }

    private func setupSideMenuPreferences() {
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuAnimationFadeStrength = Constants.menuFadeStrength
        SideMenuManager.default.menuWidth = Constants.menuWidth
    }

    func present(viewController: UIViewController, onSide side: MenuSide) {
        let menuNavigationController = UISideMenuNavigationController(rootViewController: viewController)
        menuNavigationController.isNavigationBarHidden = true

        switch side {
        case .left:
            SideMenuManager.default.menuLeftNavigationController = menuNavigationController
            present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        case .right:
            SideMenuManager.default.menuRightNavigationController = menuNavigationController
            present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
        }
    }

    func dismissSideViewController() {
        dismiss(animated: true, completion: nil)
    }
}
