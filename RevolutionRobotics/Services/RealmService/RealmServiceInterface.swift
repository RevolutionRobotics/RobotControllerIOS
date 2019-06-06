//
//  RealmServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol RealmServiceInterface: class {
    var realmConnector: RealmConnectorInterface! { get set }

    func deepCopyRobot(_ robot: UserRobot)
    func getRobots() -> [UserRobot]
    func saveRobot(_ robot: UserRobot, shouldUpdate: Bool)
    func deleteRobot(_ robot: UserRobot)
    func updateObject(closure: (() -> Void)?)
    func getConfiguration(id: String?) -> ConfigurationDataModel?
    func saveControllers(_ controllers: [ControllerDataModel])
    func getControllers() -> [ControllerDataModel]
    func deleteController(_ controller: ControllerDataModel)
    func saveConfigurations(_ configurations: [ConfigurationDataModel])
    func getChallengeCategory(id: String?) -> ChallengeCategoryDataModel?
    func saveChallengeCategory(_ category: ChallengeCategoryDataModel)
}
