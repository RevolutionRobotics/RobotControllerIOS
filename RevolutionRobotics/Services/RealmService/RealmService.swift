//
//  RealmService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift
import os

final class RealmService {
    var realmConnector: RealmConnectorInterface!
}

// MARK: - RealmServiceInterface
extension RealmService: RealmServiceInterface {
    func deepCopyRobot(_ robot: UserRobot) {
        let newRobot = UserRobot(value: robot)
        newRobot.id = UUID().uuidString
        newRobot.lastModified = Date()
        newRobot.configId = deepCopy(getConfiguration(id: robot.configId))
        newRobot.customName = (newRobot.customName ?? "") + " " + ModalKeys.RobotInfo.copyPostfix.translate()
        if let image = FileManager.default.image(for: robot.id) {
            FileManager.default.save(image, as: newRobot.id)
        }
        deepCopy(from: getConfiguration(id: robot.configId), newConfigurationId: newRobot.configId)
        saveRobot(newRobot)
    }

    private func deepCopy(_ configuration: ConfigurationDataModel?) -> String {
        guard let configuration = configuration else { return "" }
        let newConfiguration = ConfigurationDataModel(value: configuration)
        newConfiguration.id = UUID().uuidString
        newConfiguration.mapping = deepCopy(configuration.mapping)
        saveConfigurations([newConfiguration])
        return newConfiguration.id
    }

    private func deepCopy(_ mapping: PortMappingDataModel?) -> PortMappingDataModel? {
        guard let mapping = mapping else { return nil }
        let s1: SensorDataModel? = (mapping.s1 != nil) ? SensorDataModel(value: mapping.s1!) : nil
        let s2: SensorDataModel? = (mapping.s2 != nil) ? SensorDataModel(value: mapping.s2!) : nil
        let s3: SensorDataModel? = (mapping.s3 != nil) ? SensorDataModel(value: mapping.s3!) : nil
        let s4: SensorDataModel? = (mapping.s4 != nil) ? SensorDataModel(value: mapping.s4!) : nil
        let m1: MotorDataModel? = (mapping.m1 != nil) ? MotorDataModel(value: mapping.m1!) : nil
        let m2: MotorDataModel? = (mapping.m2 != nil) ? MotorDataModel(value: mapping.m2!) : nil
        let m3: MotorDataModel? = (mapping.m3 != nil) ? MotorDataModel(value: mapping.m3!) : nil
        let m4: MotorDataModel? = (mapping.m4 != nil) ? MotorDataModel(value: mapping.m4!) : nil
        let m5: MotorDataModel? = (mapping.m5 != nil) ? MotorDataModel(value: mapping.m5!) : nil
        let m6: MotorDataModel? = (mapping.m6 != nil) ? MotorDataModel(value: mapping.m6!) : nil
        return PortMappingDataModel(s1: s1, s2: s2, s3: s3, s4: s4, m1: m1, m2: m2, m3: m3, m4: m4, m5: m5, m6: m6)
    }

    private func deepCopy(from configuration: ConfigurationDataModel?, newConfigurationId: String) {
        let controllers = getControllers().filter({ $0.configurationId == configuration?.id })
        var newControllers: [ControllerDataModel] = []
        controllers.forEach { dataModel in
            let newController = ControllerDataModel(value: dataModel)
            newController.id = UUID().uuidString
            newController.configurationId = newConfigurationId
            newController.mapping = deepCopy(dataModel.mapping)
            newController.backgroundProgramBindings = deepCopy(dataModel.backgroundProgramBindings)
            newControllers.append(newController)

            if dataModel.id == configuration?.controller {
                updateObject(closure: { [weak self] in
                    self?.getConfiguration(id: newConfigurationId)?.controller = newController.id
                })
            }
        }
        saveControllers(newControllers)
    }

    private func deepCopy(_ mapping: ControllerButtonMappingDataModel?) -> ControllerButtonMappingDataModel? {
        guard let mapping = mapping else { return nil }

        let b1: ProgramBindingDataModel? = (mapping.b1 != nil) ? ProgramBindingDataModel(value: mapping.b1!) : nil
        let b2: ProgramBindingDataModel? = (mapping.b2 != nil) ? ProgramBindingDataModel(value: mapping.b2!) : nil
        let b3: ProgramBindingDataModel? = (mapping.b3 != nil) ? ProgramBindingDataModel(value: mapping.b3!) : nil
        let b4: ProgramBindingDataModel? = (mapping.b4 != nil) ? ProgramBindingDataModel(value: mapping.b4!) : nil
        let b5: ProgramBindingDataModel? = (mapping.b5 != nil) ? ProgramBindingDataModel(value: mapping.b5!) : nil
        let b6: ProgramBindingDataModel? = (mapping.b6 != nil) ? ProgramBindingDataModel(value: mapping.b6!) : nil
        return ControllerButtonMappingDataModel(b1: b1, b2: b2, b3: b3, b4: b4, b5: b5, b6: b6)
    }

    private func deepCopy(_ list: List<ProgramBindingDataModel>) -> List<ProgramBindingDataModel> {
        let newList = List<ProgramBindingDataModel>()
        Array(list).forEach { dataModel in
            newList.append(ProgramBindingDataModel(value: dataModel))
        }
        return newList
    }

    func saveConfigurations(_ configurations: [ConfigurationDataModel]) {
        realmConnector.save(objects: configurations, shouldUpdate: true)
    }

    func getRobots() -> [UserRobot] {
        guard let robots = realmConnector.findAll(type: UserRobot.self) as? [UserRobot] else { return [] }
        return robots
    }

    func getRobot(_ id: String) -> UserRobot? {
        return getRobots().first(where: { $0.id == id })
    }

    func saveRobot(_ robot: UserRobot, shouldUpdate: Bool = true) {
        realmConnector.save(object: robot, shouldUpdate: shouldUpdate)
    }

    func deleteRobot(_ robot: UserRobot) {
        let configuration = getConfiguration(id: robot.configId)!
        let programs = getPrograms().filter({ $0.robotId == robot.id })
        let controllers = getControllers().filter({ $0.configurationId == robot.configId })

        realmConnector.delete(objects: controllers)
        realmConnector.delete(objects: programs)
        realmConnector.delete(object: configuration)
        realmConnector.delete(object: robot)
    }

    func updateObject(closure: (() -> Void)?) {
        realmConnector.realm.refresh()
        do {
            try realmConnector.realm.write {
                closure?()
            }
        } catch {
            os_log("Error: Could not update object in the local database!")
        }
    }

    func getControllers() -> [ControllerDataModel] {
        guard let controllers = realmConnector.findAll(type: ControllerDataModel.self) as? [ControllerDataModel] else {
            return []
        }
        return controllers
    }

    func getController(id: String?) -> ControllerDataModel? {
        guard let id = id,
            let controllers = realmConnector.findAll(type: ControllerDataModel.self) as? [ControllerDataModel],
            let controller = controllers.first(where: { $0.id == id }) else { return nil }
        return controller
    }

    func deleteController(_ controller: ControllerDataModel) {
        return realmConnector.delete(object: controller)
    }

    func getConfiguration(id: String?) -> ConfigurationDataModel? {
        guard let id = id,
            let configurations = realmConnector.findAll(type: ConfigurationDataModel.self) as? [ConfigurationDataModel],
            let configuration = configurations.first(where: { $0.id == id }) else { return nil }
        return configuration
    }

    func getConfigurations() -> [ConfigurationDataModel] {
        guard
            let configurations = realmConnector.findAll(type: ConfigurationDataModel.self) as? [ConfigurationDataModel]
            else { return [] }
        return configurations
    }

    func saveControllers(_ controllers: [ControllerDataModel]) {
        realmConnector.save(objects: controllers, shouldUpdate: true)
    }

    func saveChallengeCategory(_ category: ChallengeCategoryDataModel) {
        realmConnector.save(object: category, shouldUpdate: true)
    }

    func getChallengeCategory(id: String?) -> ChallengeCategoryDataModel? {
        guard let categories = realmConnector.findAll(type: ChallengeCategoryDataModel.self)
            as? [ChallengeCategoryDataModel],
            let category = categories.first(where: { $0.id == id }) else { return nil }
        return category
    }

    func getPrograms() -> [ProgramDataModel] {
        guard let programs = realmConnector.findAll(type: ProgramDataModel.self) as? [ProgramDataModel] else {
            return []
        }
        return programs
    }

    func getProgram(id: String?) -> ProgramDataModel? {
        guard let id = id,
            let programs = realmConnector.findAll(type: ProgramDataModel.self) as? [ProgramDataModel],
            let program = programs.first(where: { $0.id == id }) else { return nil }
        return program
    }

    func getProgram(remoteId: String?) -> ProgramDataModel? {
        guard let id = remoteId,
            let programs = realmConnector.findAll(type: ProgramDataModel.self) as? [ProgramDataModel],
            let program = programs.first(where: { $0.remoteId == id }) else { return nil }
        return program
    }

    func savePrograms(programs: [ProgramDataModel]) {
        realmConnector.save(objects: programs, shouldUpdate: true)
    }

    func deleteProgram(_ program: ProgramDataModel) {
        return realmConnector.delete(object: program)
    }

    func saveProgramBindings(_ bindings: [ProgramBindingDataModel]) {
        realmConnector.save(objects: bindings, shouldUpdate: false)
    }
}
