//
//  Container+Unwrapped.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Swinject

extension Container {
    func unwrappedResolve<Service>(_ serviceType: Service.Type) -> Service {
        return resolve(serviceType, name: nil)!
    }
}
