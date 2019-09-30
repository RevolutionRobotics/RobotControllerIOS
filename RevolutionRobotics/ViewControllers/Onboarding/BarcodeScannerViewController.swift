//
//  BarcodeScannerViewController.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 09. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import ZXingObjC
import Firebase

final class BarcodeScannerViewController: BaseViewController {

    // MARK: - Constants
    private enum Constants {
        static let userTypeEvent = "selected_user_type"
        static let captureRotation = 270.0
        static let scanRectRotation = 0.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var scannerContainer: UIView!
    @IBOutlet private weak var skipButton: RRButton!
    @IBOutlet private weak var scanButton: RRButton!

    var userProperties: [String: String]!

    // MARK: - Properties
    private let capture = ZXCapture()
    private var isScanning = false
}

// MARK: - View lifecycle
extension BarcodeScannerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSkipButton()
        #if targetEnvironment(simulator)
            setupMockedScanner()
        #else
            setupBarcodeScanner()
        #endif
    }
}

// MARK: - Private methods
extension BarcodeScannerViewController {
    private func setupNavigationBar() {
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Font.jura(size: 18.0, weight: .bold)
        ]
    }

    private func setupBarcodeScanner() {
        capture.camera = capture.back()
        capture.focusMode = .continuousAutoFocus
        capture.delegate = self

        scannerContainer.layer.addSublayer(capture.layer)

        let angleRadius = Constants.captureRotation / 180.0 * Double.pi
        let captureTransform = CGAffineTransform(rotationAngle: CGFloat(angleRadius))

        capture.transform = captureTransform
        capture.rotation = CGFloat(Constants.scanRectRotation)
        capture.layer.frame = scannerContainer.bounds
    }

    private func setupMockedScanner() {
        scanButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.bottomLeft, .topRight])
        scanButton.isHidden = false
    }

    private func mockScanning() {
        let mockedResult = "Revolution Robotics Brain"
        userProperties[UserProperty.robotId.rawValue] = mockedResult
        reportUserInfo()
    }

    private func setupSkipButton() {
        skipButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.bottomLeft, .topRight])
    }

    private func reportUserInfo() {
        userProperties.forEach({ (key, value) in
            Analytics.setUserProperty(value, forName: key)
        })

        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: UserDefaults.Keys.userPropertiesSet)

        if userProperties.keys.contains(UserProperty.robotId.rawValue) {
            userDefaults.set(true, forKey: UserDefaults.Keys.robotRegistered)
        }

        if !userProperties.keys.isEmpty {
            Analytics.logEvent(Constants.userTypeEvent, parameters: userProperties)
        }

        let buildRevvy = AppContainer.shared.container.unwrappedResolve(BuildRevvyViewController.self)
        navigationController?.pushViewController(buildRevvy, animated: true)
    }
}

// MARK: - Actions
extension BarcodeScannerViewController {
    @IBAction private func skipButtonTapped(_ sender: Any) {
        reportUserInfo()
    }

    @IBAction private func scanButtonTapped(_ sender: Any) {
        mockScanning()
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ZXCaptureDelegate
extension BarcodeScannerViewController: ZXCaptureDelegate {
    func captureCameraIsReady(_ capture: ZXCapture!) {
        isScanning = true
    }

    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        capture?.stop()
        isScanning = false

        userProperties[UserProperty.robotId.rawValue] = result.text
        reportUserInfo()
    }
}
