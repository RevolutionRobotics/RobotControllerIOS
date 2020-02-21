//
//  RRNavigationController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRNavigationController: UINavigationController {
    private var pushedType: String?

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let targetType = String(describing: type(of: viewController))
        guard targetType != pushedType else {
            return
        }

        pushedType = String(describing: type(of: viewController))
        super.pushViewController(viewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let target = super.popViewController(animated: animated)
        pushedType = String(describing: type(of: target))

        return target
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let target = viewControllers.first
        pushedType = target != nil
            ? String(describing: type(of: target))
            : nil

        return super.popToRootViewController(animated: animated)
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        pushedType = String(describing: type(of: viewController))
        return super.popToViewController(viewController, animated: animated)
    }
}
