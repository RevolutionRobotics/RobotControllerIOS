//
//  UIViewController+ParentalGate.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 11. 21..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import PMParentalGate

extension UIViewController {
    func showParentalGate(then callback: Callback?) {
        guard let gate = PMParentalGateQuestion.sharedGate() as? PMParentalGateQuestion else { return }
        let gateTitle = CommonKeys.parentalGateTitle.translate()
        gate.presentGate(withText: gateTitle, timeout: 40, finishedBlock: { [weak self] pass, _ in
            guard let `self` = self else { return }
            guard pass else {
                let alert = UIAlertController.errorAlert(type: .parentalGateFailed)
                self.present(alert, animated: true, completion: nil)
                return
            }

            callback?()
        })
    }
}
