//
//  RealmServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol RealmServiceInterface: class {
    var realmConnector: RealmConnectorInterface! { get set }

    func updateObject(closure: (() -> Void)?)

    func getRobots() -> [UserRobot]
    func getRobot(_ id: String) -> UserRobot?
    func saveRobot(_ robot: UserRobot, shouldUpdate: Bool)
    func deleteRobot(_ robot: UserRobot)
    func deepCopyRobot(_ robot: UserRobot)

    func getConfiguration(id: String?) -> ConfigurationDataModel?
    func getConfigurations() -> [ConfigurationDataModel]
    func saveConfigurations(_ configurations: [ConfigurationDataModel])

    func getControllers() -> [ControllerDataModel]
    func getController(id: String?) -> ControllerDataModel?
    func saveControllers(_ controllers: [ControllerDataModel])
    func deleteController(_ controller: ControllerDataModel)

    func getChallengeCategory(id: String?) -> ChallengeCategoryDataModel?
    func saveChallengeCategory(_ category: ChallengeCategoryDataModel)
    func saveChallenges(_ challenges: [ChallengeDataModel])
    func getChallenges() -> [ChallengeDataModel]

    func getPrograms() -> [ProgramDataModel]
    func getProgram(id: String?) -> ProgramDataModel?
    func getProgram(remoteId: String?) -> ProgramDataModel?
    func savePrograms(programs: [ProgramDataModel])
    func deleteProgram(_ program: ProgramDataModel)

    func saveProgramBindings(_ bindings: [ProgramBindingDataModel])
}
