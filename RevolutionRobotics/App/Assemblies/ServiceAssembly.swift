//
//  ServiceAssembly.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Swinject

final class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        registerFirebaseService(to: container)
    }
}

extension ServiceAssembly {
    private func registerFirebaseService(to container: Container) {
        container
            .register(FirebaseServiceInterface.self, factory: { _ in return FirebaseService() })
            .inObjectScope(.container)
    }
}
