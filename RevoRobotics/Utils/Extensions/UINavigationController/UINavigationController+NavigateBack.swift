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
}
