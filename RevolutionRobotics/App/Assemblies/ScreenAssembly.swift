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
        registerWhoToBuildViewController(to: container)
        registerYourRobotsViewController(to: container)
        registerBuildRobotViewController(to: container)
        registerModalViewController(to: container)
        registerConfigurationViewController(to: container)
        registerMotorConfigViewController(to: container)
        registerSensorConfigViewController(to: container)
        registerPlayControllerViewController(to: container)
        registerFirmwareUpdateViewController(to: container)
        registerAboutViewController(to: container)
        registerControllerSelectorViewController(to: container)
        registerProgramsBottomViewController(to: container)
    }
}

extension ScreenAssembly {
    private func registerMenuViewController(to container: Container) {
        container
            .register(MenuViewController.self, factory: { _ in return MenuViewController() })
            .inObjectScope(.weak)
    }

    private func registerBlocklyViewController(to container: Container) {
        container
            .register(BlocklyViewController.self, factory: { _ in return BlocklyViewController() })
            .inObjectScope(.weak)
    }

    private func registerChallengesViewController(to container: Container) {
        container
            .register(ChallengesViewController.self, factory: { _ in return ChallengesViewController() })
            .inObjectScope(.weak)
    }

    private func registerProgramsViewController(to container: Container) {
        container
            .register(ProgramsViewController.self, factory: { _ in return ProgramsViewController() })
            .inObjectScope(.weak)
    }

    private func registerSettingsViewController(to container: Container) {
        container
            .register(SettingsViewController.self, factory: { _ in return SettingsViewController() })
            .inObjectScope(.weak)
    }

    private func registerWhoToBuildViewController(to container: Container) {
        container
            .register(WhoToBuildViewController.self, factory: { _ in return WhoToBuildViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerYourRobotsViewController(to container: Container) {
        container
            .register(YourRobotsViewController.self, factory: { _ in return YourRobotsViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerBuildRobotViewController(to container: Container) {
        container
            .register(BuildRobotViewController.self, factory: { _ in return BuildRobotViewController() })
            .initCompleted { (resolver, buildRobotViewController) in
                buildRobotViewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
                buildRobotViewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerModalViewController(to container: Container) {
        container
            .register(ModalViewController.self, factory: { _ in return ModalViewController() })
            .inObjectScope(.transient)
    }

    private func registerConfigurationViewController(to container: Container) {
        container
            .register(ConfigurationViewController.self, factory: { _ in return ConfigurationViewController() })
            .initCompleted({ (resolver, configurationViewController) in
                configurationViewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                configurationViewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            })
            .inObjectScope(.weak)
    }

    private func registerMotorConfigViewController(to container: Container) {
        container
            .register(MotorConfigViewController.self, factory: { _ in return MotorConfigViewController() })
            .inObjectScope(.transient)
    }

    private func registerSensorConfigViewController(to container: Container) {
        container
            .register(SensorConfigViewController.self, factory: { _ in return SensorConfigViewController() })
            .inObjectScope(.transient)
    }

    private func registerPlayControllerViewController(to container: Container) {
        container
            .register(PlayControllerViewController.self, factory: { _ in return PlayControllerViewController() })
            .initCompleted { (resolver, playControllerViewController) in
                playControllerViewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)
            }
            .inObjectScope(.weak)
    }

    private func registerFirmwareUpdateViewController(to container: Container) {
        container
            .register(FirmwareUpdateViewController.self, factory: { _ in return FirmwareUpdateViewController() })
            .inObjectScope(.weak)
    }

    private func registerAboutViewController(to container: Container) {
        container
            .register(AboutViewController.self, factory: { _ in return AboutViewController() })
            .inObjectScope(.weak)
    }

    private func registerControllerSelectorViewController(to container: Container) {
        container
            .register(ControllerLayoutSelectorViewController.self, factory: { _ in
                return ControllerLayoutSelectorViewController()
            })
            .inObjectScope(.weak)
    }

    private func registerProgramsBottomViewController(to container: Container) {
        container
            .register(ProgramBottomBarViewController.self, factory: { _ in return ProgramBottomBarViewController() })
            .inObjectScope(.transient)
    }
}
