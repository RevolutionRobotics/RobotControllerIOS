//
//  ControllerViewModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

final class ControllerViewModel {
    // MARK: - Properties
    var id: String = ""
    var configurationId: String = ""
    var name: String = ""
    var customDesctiprion: String = ""
    var type: ControllerType!
    var b1Binding: ProgramBindingDataModel?
    var b2Binding: ProgramBindingDataModel?
    var b3Binding: ProgramBindingDataModel?
    var b4Binding: ProgramBindingDataModel?
    var b5Binding: ProgramBindingDataModel?
    var b6Binding: ProgramBindingDataModel?

    var b1Program: ProgramDataModel?
    var b2Program: ProgramDataModel?
    var b3Program: ProgramDataModel?
    var b4Program: ProgramDataModel?
    var b5Program: ProgramDataModel?
    var b6Program: ProgramDataModel?

    var backgroundPrograms: [ProgramDataModel] = [] {
        didSet {
            let ids = backgroundPrograms.map({ $0.id })
            let remoteIds = backgroundPrograms.map({ $0.remoteId })
            backgroundProgramBindings =
                backgroundProgramBindings.filter({ ids.contains($0.programId) || remoteIds.contains($0.programId) })
            ids.forEach({ id in
                if backgroundProgramBindings.first(where: { $0.programId == id }) == nil {
                    backgroundProgramBindings.append(ProgramBindingDataModel(programId: id, priority: 1))
                }
            })
        }
    }
    var backgroundProgramBindings: [ProgramBindingDataModel] = []

    var joystickPriority: Int = 0
    var isNewlyCreated = false
    var programs: [ProgramDataModel] {
        return [b1Program, b2Program, b3Program, b4Program, b5Program, b6Program].compactMap({ $0 })
            + backgroundPrograms
    }

    var buttonPrograms: [ProgramDataModel] {
        return [b1Program, b2Program, b3Program, b4Program, b5Program, b6Program].compactMap({ $0 })
    }

    private var bindings: [ProgramBindingDataModel] {
        return [b1Binding, b2Binding, b3Binding, b4Binding, b5Binding, b6Binding].compactMap({ $0 })
            + backgroundProgramBindings
    }

    var priorityOrderedPrograms: [ProgramDataModel] {
        var dictionary: [Int: [ProgramDataModel]] = [:]
        var ordered: [ProgramDataModel] = []
        if let binding = b1Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }
        if let binding = b2Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }
        if let binding = b3Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }
        if let binding = b4Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }
        if let binding = b5Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }
        if let binding = b6Binding, let program = programs.first(where: { $0.id == binding.programId }) ??
            programs.first(where: { $0.remoteId == binding.programId }) {
            if dictionary[binding.priority] == nil {
                dictionary[binding.priority] = [program]
            } else {
                var array = dictionary[binding.priority]
                array?.append(program)
                dictionary[binding.priority] = array
            }
        }

        backgroundProgramBindings.forEach({ element in
            guard let program = backgroundPrograms.first(where: { $0.id == element.programId }) ??
                backgroundPrograms.first(where: { $0.remoteId == element.programId }) else { return }
            if dictionary[element.priority] == nil {
                dictionary[element.priority] = [program]
            } else {
                var array = dictionary[element.priority]
                array?.append(program)
                dictionary[element.priority] = array
            }
        })
        dictionary.sorted(by: { $0.key < $1.key }).forEach({ ordered += $1 })
        return ordered
    }

    func isBackgroundProgram(_ program: ProgramDataModel) -> Bool {
        return backgroundPrograms.contains(program)
    }
}

extension ControllerViewModel {
    func programSelected(_ program: ProgramDataModel?, on buttonNumber: Int) {
        switch buttonNumber {
        case 1:
            b1Program = program
            b1Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        case 2:
            b2Program = program
            b2Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        case 3:
            b3Program = program
            b3Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        case 4:
            b4Program = program
            b4Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        case 5:
            b5Program = program
            b5Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        case 6:
            b6Program = program
            b6Binding = program?.id != nil ? ProgramBindingDataModel(programId: (program?.id)!, priority: 1) : nil
        default: break
        }
    }
}
