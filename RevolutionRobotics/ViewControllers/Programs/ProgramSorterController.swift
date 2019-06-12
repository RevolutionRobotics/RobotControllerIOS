//
//  ProgramSorter.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

final class ProgramSorter {
    enum Field {
        case name
        case date
    }

    enum Order {
        case ascending
        case descending
    }

    struct Options {
        var field: Field
        var order: Order
    }

    func sort(programs: [ProgramDataModel], options: Options) -> [ProgramDataModel] {
        return sort(programs: programs, by: options.field, order: options.order)
    }

    func sort(programs: [ProgramDataModel], by sortingField: Field, order: Order) -> [ProgramDataModel] {
        return sortingField == .name
            ? sortProgramsByName(programs, order: order)
            : sortProgramsByDate(programs, order: order)
    }

    private func sortProgramsByName(_ programs: [ProgramDataModel], order: Order) -> [ProgramDataModel] {
        return programs.sorted(by: {
            switch order {
            case .ascending:
                return $0.name < $1.name
            case .descending:
                return $0.name > $1.name
            }
        })
    }

    private func sortProgramsByDate(_ programs: [ProgramDataModel], order: Order) -> [ProgramDataModel] {
        return programs.sorted(by: {
            switch order {
            case .ascending:
                return $0.lastModified < $1.lastModified
            case .descending:
                return $0.lastModified > $1.lastModified
            }
        })
    }
}
