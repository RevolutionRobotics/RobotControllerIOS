//
//  RealmService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class RealmService {
    var realmConnector: RealmConnectorInterface!
}

// MARK: - RealmServiceInterface
extension RealmService: RealmServiceInterface {
    func saveConfigurations(_ configurations: [ConfigurationDataModel]) {
        realmConnector.save(objects: configurations, shouldUpdate: true)
    }

    func getRobots() -> [UserRobot] {
        guard let robots = realmConnector.findAll(type: UserRobot.self) as? [UserRobot] else { return [] }
        return robots
    }

    func saveRobot(_ robot: UserRobot, shouldUpdate: Bool = true) {
        realmConnector.save(object: robot, shouldUpdate: shouldUpdate)
    }

    func deleteRobot(_ robot: UserRobot) {
        return realmConnector.delete(object: robot)
    }

    func updateObject(closure: (() -> Void)?) {
        realmConnector.realm.refresh()
        do {
            try realmConnector.realm.write {
                closure?()
            }
        } catch {
            print(error)
        }
    }

    func getControllers() -> [Controller] {
        return []
    }

    func getConfiguration(id: Int?) -> ConfigurationDataModel? {
        guard let id = id,
            let configurations = realmConnector.findAll(type: ConfigurationDataModel.self) as? [ConfigurationDataModel],
            let configuration = configurations.first(where: { $0.id == id }) else { return nil }
        return configuration
    }
}
