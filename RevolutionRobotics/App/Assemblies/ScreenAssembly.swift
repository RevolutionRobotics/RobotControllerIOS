//
//  ScreenAssembly.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Swinject
import RevolutionRoboticsBlockly

final class ScreenAssembly: Assembly {
    func assemble(container: Container) {
        registerMenuViewController(to: container)
        registerBlocklyViewController(to: container)
        registerChallengesViewController(to: container)
        registerProgramsViewController(to: container)
        registerSettingsViewController(to: container)
    }
}

extension ScreenAssembly {
    private func registerMenuViewController(to container: Container) {
        container.register(MenuViewController.self, factory: { _ in return MenuViewController() }).inObjectScope(.weak)
    }

    private func registerBlocklyViewController(to container: Container) {
        container.register(BlocklyViewController.self, factory: { _ in return BlocklyViewController() })
            .inObjectScope(.weak)
    }

    private func registerChallengesViewController(to container: Container) {
        container.register(ChallengesViewController.self, factory: { _ in return ChallengesViewController() })
            .inObjectScope(.weak)
    }

    private func registerProgramsViewController(to container: Container) {
        container.register(ProgramsViewController.self, factory: { _ in return ProgramsViewController() })
            .inObjectScope(.weak)
    }

    private func registerSettingsViewController(to container: Container) {
        container.register(SettingsViewController.self, factory: { _ in return SettingsViewController() })
            .inObjectScope(.weak)
    }
}
