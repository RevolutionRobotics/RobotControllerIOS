//
//  RealmServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol RealmServiceInterface: class {
    var realmConnector: RealmConnectorInterface! { get set }

    func getRobots() -> [UserRobot]
    func saveRobot(_ robot: UserRobot, shouldUpdate: Bool)
    func deleteRobot(_ robot: UserRobot)
    func updateObject(closure: (() -> Void)?)
    func getConfiguration(id: Int?) -> ConfigurationDataModel?
    func getControllers() -> [Int]
    func saveConfigurations(_ configurations: [ConfigurationDataModel])
}
