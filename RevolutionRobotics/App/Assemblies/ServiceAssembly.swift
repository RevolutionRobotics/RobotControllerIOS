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
        registerRealmConnector(to: container)
        registerRealmService(to: container)
        registerBluetoothService(to: container)
    }
}

extension ServiceAssembly {
    private func registerFirebaseService(to container: Container) {
        container
            .register(FirebaseServiceInterface.self, factory: { _ in return FirebaseService() })
            .inObjectScope(.container)
    }

    private func registerRealmConnector(to container: Container) {
        container
            .register(RealmConnectorInterface.self, factory: { _ in return RealmConnector() })
            .inObjectScope(.container)
    }

    private func registerRealmService(to container: Container) {
        container
            .register(RealmServiceInterface.self, factory: { _ in return RealmService() })
            .initCompleted({ (resolver, service) in
                service.realmConnector = resolver.resolve(RealmConnectorInterface.self)!
            })
            .inObjectScope(.container)
    }

    private func registerBluetoothService(to container: Container) {
        container
            .register(BluetoothServiceInterface.self, factory: { _ in return BluetoothService() })
            .inObjectScope(.container)
    }
}
