//
//  UINavigationController+NavigateBack.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 28..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Swinject

extension UINavigationController {
    func pop<T: UIViewController>(to type: T.Type) {
        let viewController = AppContainer.shared.container.unwrappedResolve(type)
        if viewControllers.contains(viewController) {
            popToViewController(viewController, animated: true)
        }
    }

    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping Callback) {
        pushViewController(viewController, animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping Callback) {
        popViewController(animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
