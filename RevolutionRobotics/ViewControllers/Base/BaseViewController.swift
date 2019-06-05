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

    // MARK: - Properties
    private var onModalDismissed: Callback?

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
    func presentModal(
        with contentView: UIView,
        animated: Bool = true,
        closeHidden: Bool = false,
        onDismissed: Callback? = nil
    ) {
        let modalViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        onModalDismissed = onDismissed
        modalViewController.modalPresentationStyle = .overFullScreen
        modalViewController.modalTransitionStyle = .crossDissolve
        modalViewController.delegate = self
        modalViewController.contentView = contentView
        modalViewController.isCloseHidden = closeHidden
        present(modalViewController, animated: animated)
    }

    func presentSafariModal(presentationFinished: Callback?, url: URL? = nil) {
        if self.presentedViewController != nil {
            dismiss(animated: true, completion: { [weak self] in
                self?.presentSafari(presentationFinished: presentationFinished, url: url)
            })
        } else {
            presentSafari(presentationFinished: presentationFinished, url: url)
        }
    }

    func presentViewControllerModally(
        _ viewController: UIViewController,
        transitionStyle: UIModalTransitionStyle = .coverVertical,
        presentationStyle: UIModalPresentationStyle = .overFullScreen
    ) {
        viewController.modalTransitionStyle = transitionStyle
        viewController.modalPresentationStyle = presentationStyle
        present(viewController, animated: true, completion: nil)
    }

    private func presentSafari(presentationFinished: Callback?, url: URL?) {
        let communityViewController = CommunityViewController(url: url ?? Constants.communityURL)
        communityViewController.presentationFinished = presentationFinished
        communityViewController.modalPresentationStyle = .overFullScreen
        present(communityViewController, animated: true, completion: nil)
    }
}

// MARK: - ModalViewControllerDelegate
extension BaseViewController: ModalViewControllerDelegate {
    func dismissViewController() {
        onModalDismissed?()
        onModalDismissed = nil
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

    func present(viewController: (UIViewController & UISideMenuNavigationControllerDelegate), onSide side: MenuSide) {
        let menuNavigationController = UISideMenuNavigationController(rootViewController: viewController)
        menuNavigationController.sideMenuDelegate = viewController
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
}

// MARK: - Bluetooth connection
extension BaseViewController {
    func subscribeForConnectionChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connected),
                                               name: .robotConnected,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disconnected),
                                               name: .robotDisconnected,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(connectionError),
                                               name: .robotConnectionError,
                                               object: nil)
    }

    func unsubscribeFromConnectionChange() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func connected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissViewController()
        }
    }

    @objc func disconnected() { }
    @objc func connectionError() { }
}
