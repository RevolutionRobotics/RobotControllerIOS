//
//  BaseViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
import os

class BaseViewController: UIViewController, RRNavigationBarDelegate {
    // MARK: - Constants
    private enum Constants {
        static let menuFadeStrength: CGFloat = 0.65
        static let menuWidth: CGFloat = max(UIScreen.main.bounds.width / 3, 215.0)
        static let communityURL: URL = URL(string: "https://revolutionrobotics.discourse.group")!
        static let keyboardTopSpace: CGFloat = 20
    }

    // MARK: - Properties
    private var onModalDismissed: Callback?
    private var shouldDismissOnBackgroundTap: Bool = true
    private let modalPresenter = BluetoothConnectionModalPresenter()
    var bluetoothService: BluetoothServiceInterface!
    var screenName: String?

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
        navigationController?.delegate = self

        setupSideMenuPreferences()
        registerObserver()
        subscribeForConnectionChange()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName()
    }
}

// MARK: - Firebase Analytics
extension BaseViewController {
    private func setScreenName() {
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let screenName = screenName
        else { return }

        appDelegate.currentScreenName = screenName
        Analytics.setScreenName(screenName, screenClass: classForCoder.description())
    }

    func logEvent(named name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
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
        onDismissed: Callback? = nil,
        shouldDismissOnBackgroundTap: Bool = true) {
        let modalViewController = AppContainer.shared.container.unwrappedResolve(ModalViewController.self)
        onModalDismissed = onDismissed
        modalViewController.delegate = self
        modalViewController.contentView = contentView
        modalViewController.isCloseHidden = closeHidden
        self.shouldDismissOnBackgroundTap = shouldDismissOnBackgroundTap
        presentViewControllerModally(
            modalViewController,
            transitionStyle: .crossDissolve,
            presentationStyle: .overFullScreen
        )
    }

    func presentUndismissableModal(with contentView: UIView, animated: Bool) {
        presentModal(
            with: contentView,
            animated: animated,
            closeHidden: true,
            onDismissed: nil,
            shouldDismissOnBackgroundTap: false)
    }

    func openSafari(presentationFinished: Callback?, url: URL? = nil) {
        showParentalGate(then: { [weak self] in
            guard let `self` = self else { return }
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: { [weak self] in
                    self?.presentSafari(with: url, callback: presentationFinished)
                })
            } else {
                self.presentSafari(with: url, callback: presentationFinished)
            }
        })
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

    private func presentSafari(with url: URL?, callback: Callback?) {
        if url == nil || url == Constants.communityURL {
            logEvent(named: "open_forum")
        }

        UIApplication.shared.open(url ?? Constants.communityURL, options: [:], completionHandler: { _ in
            callback?()
        })
    }
}

// MARK: - UINavigationControllerDelegate
extension BaseViewController: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_
        navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return .landscapeRight
    }
}

// MARK: - ModalViewControllerDelegate
extension BaseViewController: ModalViewControllerDelegate {
    func dismissModalViewController() {
        if presentedViewController is ModalViewController || presentedViewController is Dismissable {
            dismiss(animated: true, completion: {
                self.onModalDismissed?()
                self.onModalDismissed = nil
            })
        } else if presentedViewController?.presentedViewController is ModalViewController {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func backgroundTapped() {
        if shouldDismissOnBackgroundTap {
            dismiss(animated: true, completion: {
                self.onModalDismissed?()
                self.onModalDismissed = nil
            })
        }
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
                guard let `self` = self else { return }
                self.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure:
                        os_log("Error: Failed to discover peripherals!")
                    }
                })
                self.logEvent(named: "open_bt_device_list", params: [
                    "screen": self.screenName ?? "Unknown"
                ])
            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            onDismissed: { [weak self] in
                self?.bluetoothService.stopDiscovery()
        })
        logEvent(named: "open_bt_connect_dialog", params: [
            "screen": screenName ?? "Unknown"
        ])
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
        guard let service = bluetoothService as? BluetoothService else {
            return
        }

        service.stopDiscovery()

        let topViewController = navigationController?.topViewController
        let isFirmwareUpdateScreen = topViewController is FirmwareUpdateViewController
        let robotConfig = topViewController as? RobotConfigurationViewController

        if topViewController == self || (robotConfig?.shouldCloseConnectionModal ?? false) {
            dismissModalViewController()
            if service.robotNeedsUpdate && !isFirmwareUpdateScreen {
                let firmwareUpdateModal = FirmwareUpdateModalView.instatiate()
                firmwareUpdateModal.updatePressedCallback = { [weak self] in
                    guard let `self` = self else { return }

                    let updateViewController = AppContainer
                        .shared
                        .container
                        .unwrappedResolve(FirmwareUpdateViewController.self)

                    self.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
                        self?.navigationController?.pushViewController(updateViewController, animated: true)
                    })
                }
                firmwareUpdateModal.continuePressedCallback = { [weak self] in
                    guard let `self` = self else { return }
                    self.dismissModalViewController()
                    self.robotSoftwareApproved()
                }

                presentModal(with: firmwareUpdateModal, closeHidden: true)
            } else {
                let connectionModal = ConnectionModalView.instatiate()
                presentModal(with: connectionModal.successful, closeHidden: true)

                robotSoftwareApproved()
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.dismissModalViewController()
                }
            }
        }

        logEvent(named: "connect_to_brain", params: [
            "screen": screenName ?? "Unknown"
        ])
    }

    @objc func disconnected() { }
    @objc func connectionError() { }
    @objc func robotSoftwareApproved() { }
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
