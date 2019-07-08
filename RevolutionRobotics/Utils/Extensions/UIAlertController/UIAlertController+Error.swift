//
//  UIAlertController+Error.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIAlertController {
    enum ErrorType {
        case network
        case bluetooth
        case variableNameEmpty
        case variableNameAlreadyInUse
    }

    static func errorAlert(type: ErrorType) -> UIAlertController {
        switch type {
        case .network:
            return networkAlert()
        case .bluetooth:
            return bluetoothAlert()
        case .variableNameEmpty:
            return variableNameEmptyAlert()
        case .variableNameAlreadyInUse:
            return variableNameAlreadyInUse()
        }
    }

    private static func networkAlert() -> UIAlertController {
        let alertController = UIAlertController(title: CommonKeys.errorTitle.translate(),
                                                message: CommonKeys.general.translate(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        return alertController
    }

    private static func bluetoothAlert() -> UIAlertController {
        let alertController = UIAlertController(title: CommonKeys.errorTitle.translate(),
                                                message: CommonKeys.bluetoothErrorDescription.translate(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        let settingsAction = UIAlertAction(
            title: CommonKeys.bluetoothErrorSettings.translate(),
            style: .default,
            handler: { _ in
                alertController.dismiss(animated: true, completion: nil)
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
        })
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        return alertController
    }

    private static func variableNameEmptyAlert() -> UIAlertController {
        let alertController = UIAlertController(title: CommonKeys.errorTitle.translate(),
                                                message: RobotsKeys.Configure.variableEmpty.translate(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        return alertController
    }

    private static func variableNameAlreadyInUse() -> UIAlertController {
        let alertController = UIAlertController(title: CommonKeys.errorTitle.translate(),
                                                message: RobotsKeys.Configure.variableError.translate(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        return alertController
    }
}
