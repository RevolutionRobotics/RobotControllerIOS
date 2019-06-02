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

    func sort(programs: [Program], options: Options) -> [Program] {
        return sort(programs: programs, by: options.field, order: options.order)
    }

    func sort(programs: [Program], by sortingField: Field, order: Order) -> [Program] {
        return sortingField == .name
            ? sortProgramsByName(programs, order: order)
            : sortProgramsByDate(programs, order: order)
    }

    private func sortProgramsByName(_ programs: [Program], order: Order) -> [Program] {
        return programs.sorted(by: {
            switch order {
            case .ascending:
                return $0.name < $1.name
            case .descending:
                return $0.name > $1.name
            }
        })
    }

    private func sortProgramsByDate(_ programs: [Program], order: Order) -> [Program] {
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
