//
//  ProgramCompatibilityValidator.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 26..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class ProgramCompatibilityValidator {
    // MARK: - Properties
    private let realmService: RealmServiceInterface

    // MARK: - Initialization
    init(realmService: RealmServiceInterface) {
        self.realmService = realmService
    }
}

// MARK: - Validation
extension ProgramCompatibilityValidator {
    func validate(program: ProgramDataModel) {
        let controllersForProgram = realmService.getControllers().filter { controller in
                checkContainment(of: program, in: buttonProgramBindings(in: controller)) ||
                checkContainment(of: program, in: controller.backgroundProgramBindings.compactMap { $0 })
            }

        let incompatibleConfigurationIDs = controllersForProgram
            .compactMap { realmService.getConfiguration(id: $0.configurationId) }
            .filter { checkIncompatibility(of: program.variableNames.compactMap { $0 }, in: $0) }
            .map { $0.id }

        controllersForProgram
            .filter { incompatibleConfigurationIDs.contains($0.configurationId) }
            .forEach { detachProgram(program, from: $0) }
    }
}

// MARK: - Private methods
extension ProgramCompatibilityValidator {
    private func checkContainment(of program: ProgramDataModel, in programBindings: [ProgramBindingDataModel]) -> Bool {
        return programBindings.reduce(false, { (previousResult, programBinding) in
            return previousResult || isSameProgram(program, in: programBinding)
        })
    }

    private func checkIncompatibility(of variableNames: [String], in configuration: ConfigurationDataModel) -> Bool {
        guard let portMappingNames = configuration.mapping?.variableNames else { return false }
        return variableNames.reduce(false, { (previousResult, variableName) in
            return previousResult || !portMappingNames.contains(variableName)
        })
    }

    private func detachProgram(_ program: ProgramDataModel, from controller: ControllerDataModel) {
        if let backgroundProgramIndex = controller.backgroundProgramBindings.firstIndex(where: { programBinding in
            isSameProgram(program, in: programBinding)
        }) {
            realmService.updateObject {
                controller.backgroundProgramBindings.remove(at: backgroundProgramIndex)
            }
            return
        }

        if let b1 = controller.mapping?.b1, isSameProgram(program, in: b1) {
            realmService.updateObject {
                controller.mapping?.b1 = nil
            }
            return
        }

        if let b2 = controller.mapping?.b2, isSameProgram(program, in: b2) {
            realmService.updateObject {
                controller.mapping?.b2 = nil
            }
            return
        }

        if let b3 = controller.mapping?.b3, isSameProgram(program, in: b3) {
            realmService.updateObject {
                controller.mapping?.b3 = nil
            }
            return
        }

        if let b4 = controller.mapping?.b4, isSameProgram(program, in: b4) {
            realmService.updateObject {
                controller.mapping?.b4 = nil
            }
            return
        }

        if let b5 = controller.mapping?.b5, isSameProgram(program, in: b5) {
            realmService.updateObject {
                controller.mapping?.b5 = nil
            }
            return
        }

        if let b6 = controller.mapping?.b6, isSameProgram(program, in: b6) {
            realmService.updateObject {
                controller.mapping?.b6 = nil
            }
            return
        }
    }

    private func buttonProgramBindings(in controller: ControllerDataModel) -> [ProgramBindingDataModel] {
        guard let mapping = controller.mapping else { return [] }
        let bindings = [mapping.b1, mapping.b2, mapping.b3, mapping.b4, mapping.b5, mapping.b6]

        return bindings.compactMap { $0 }
    }

    private func isSameProgram(_ program: ProgramDataModel, in programBinding: ProgramBindingDataModel) -> Bool {
        return programBinding.programId == program.id || programBinding.programId == program.remoteId
    }
}
