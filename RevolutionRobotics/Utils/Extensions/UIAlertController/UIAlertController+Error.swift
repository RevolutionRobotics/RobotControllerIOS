//
//  UIAlertController+Error.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 22..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func errorAlert(message: String) -> UIAlertController {
        let alertController = UIAlertController(title: CommonKeys.errorTitle.translate(),
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: CommonKeys.errorOk.translate(), style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        return alertController
    }
}
