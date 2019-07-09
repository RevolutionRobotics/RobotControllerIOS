//
//  BaseViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu
import os

class BaseViewController: UIViewController, RRNavigationBarDelegate {
    // MARK: - Constants
    private enum Constants {
        static let menuFadeStrength: CGFloat = 0.65
        static let menuWidth: CGFloat = UIScreen.main.bounds.width / 3 < 215.0 ? 215.0 : UIScreen.main.bounds.width / 3
        static let communityURL: URL = URL(string: "https://revolutionrobotics.discourse.group")!
        static let keyboardTopSpace: CGFloat = 20
    }

    // MARK: - Properties
    private var onModalDismissed: Callback?
    private let modalPresenter = BluetoothConnectionModalPresenter()
    var bluetoothService: BluetoothServiceInterface!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    // MARK: - Initialization
    init() {
        super.init(nibName: type(of: self).nibName, bundle: Bundle(for: type(of: self)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        unsubscribeFromConnectionChange()
        unregisterObserver()
    }

    // MARK: - RRNavigationBarDelegate
    func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }

    func popToRootViewController(animated: Bool) {
        self.dismissModalViewController()
        navigationController?.popToRootViewController(animated: animated)
    }

    func bluetoothButtonTapped() {
        guard bluetoothService.connectedDevice != nil else {
            presentConnectModal()
            return
        }

        presentDisconnectModal()
    }
}

// MARK: - View lifecycle
extension BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSideMenuPreferences()
        registerObserver()
        subscribeForConnectionChange()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

// MARK: - Navigation
extension BaseViewController {
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Modal
extension BaseViewController {
    func presentModal(
        with contentView: UIView,
        animated: Bool = true,
        closeHidden: Bool = false,
        onDismissed: Callback? = nil) {
        let modalViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        onModalDismissed = onDismissed
        modalViewController.delegate = self
        modalViewController.contentView = contentView
        modalViewController.isCloseHidden = closeHidden
        presentViewControllerModally(
            modalViewController,
            transitionStyle: .crossDissolve,
            presentationStyle: .overFullScreen
        )
    }

    func openSafari(presentationFinished: Callback?, url: URL? = nil) {
        if self.presentedViewController != nil {
            dismiss(animated: true, completion: {
                UIApplication.shared.open(url ?? Constants.communityURL, options: [:], completionHandler: { (_) in
                    presentationFinished?()
                })
            })
        } else {
            UIApplication.shared.open(url ?? Constants.communityURL, options: [:], completionHandler: { (_) in
                presentationFinished?()
            })
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
}

// MARK: - ModalViewControllerDelegate
extension BaseViewController: ModalViewControllerDelegate {
    func dismissModalViewController() {
        if presentedViewController is ModalViewController || presentedViewController is Dismissable {
            dismiss(animated: true, completion: nil)
        } else if presentedViewController?.presentedViewController is ModalViewController {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func backgroundTapped() {
        onModalDismissed?()
        onModalDismissed = nil
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Side menu
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
    func presentConnectModal() {
        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            isBluetoothPoweredOn: bluetoothService.isBluetoothPoweredOn,
            startDiscoveryHandler: { [weak self] in
                self?.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure:
                        os_log("Error: Failed to discover peripherals!")
                    }
                })

            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            onDismissed: { [weak self] in
                self?.bluetoothService.stopDiscovery()
        })
    }

    private func presentDisconnectModal() {
        let view = DisconnectModalView.instatiate()
        view.robotName = bluetoothService.connectedDevice?.name
        view.disconnectHandler = { [weak self] in
            self?.bluetoothService.disconnect(shouldReconnect: false)
            self?.dismissModalViewController()
        }
        view.cancelHandler = { [weak self] in
            self?.dismissModalViewController()
        }
        presentModal(with: view)
    }

    private func subscribeForConnectionChange() {
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

    private func unsubscribeFromConnectionChange() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func connected() {
        bluetoothService.stopDiscovery()
        dismissModalViewController()
        let connectionModal = ConnectionModalView.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissModalViewController()
        }
    }

    @objc func disconnected() { }
    @objc func connectionError() { }
}

// MARK: Keyboard
extension BaseViewController {
    private func registerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
