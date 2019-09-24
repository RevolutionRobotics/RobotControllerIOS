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
        registerMenuTutorialViewController(to: container)
        registerBlocklyViewController(to: container)
        registerChallengeCategoriesViewController(to: container)
        registerChallengesViewController(to: container)
        registerChallengeDetailsViewController(to: container)
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
        registerPadConfigurationViewController(to: container)
        registerProgramSelectorViewController(to: container)
        registerDialpadViewController(to: container)
        registerButtonlessProgramsViewController(to: container)
        registerProgramsOrderViewController(to: container)
        registerCommunityViewController(to: container)
        registerUserTypeSelectionViewController(to: container)
        registerBarcodeScannerViewController(to: container)
        registerBuildCarbyViewController(to: container)
    }
}

extension ScreenAssembly {
    private func registerUserTypeSelectionViewController(to container: Container) {
        container
            .register(UserTypeSelectionViewController.self, factory: { _ in return UserTypeSelectionViewController() })
            .inObjectScope(.weak)
    }

    private func registerBarcodeScannerViewController(to container: Container) {
        container
            .register(BarcodeScannerViewController.self, factory: { _ in return BarcodeScannerViewController() })
            .inObjectScope(.weak)
    }

    private func registerBuildCarbyViewController(to container: Container) {
        container
            .register(BuildCarbyViewController.self, factory: { _ in return
                BuildCarbyViewController()
            })
            .inObjectScope(.weak)
    }

    private func registerMenuViewController(to container: Container) {
        container
            .register(MenuViewController.self, factory: { _ in return MenuViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerMenuTutorialViewController(to container: Container) {
        container
            .register(MenuTutorialViewController.self, factory: { _ in return MenuTutorialViewController() })
            .inObjectScope(.weak)
    }

    private func registerBlocklyViewController(to container: Container) {
        container
            .register(BlocklyViewController.self, factory: { _ in return BlocklyViewController() })
            .inObjectScope(.weak)
    }

    private func registerChallengeCategoriesViewController(to container: Container) {
        container
            .register(ChallengeCategoriesViewController.self, factory: { _ in
                return ChallengeCategoriesViewController()
            })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerChallengesViewController(to container: Container) {
        container
            .register(ChallengesViewController.self, factory: { _ in return ChallengesViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerChallengeDetailsViewController(to container: Container) {
        container
            .register(ChallengeDetailViewController.self, factory: { _ in return ChallengeDetailViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerProgramsViewController(to container: Container) {
        container
            .register(ProgramsViewController.self, factory: { _ in return ProgramsViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerSettingsViewController(to container: Container) {
        container
            .register(SettingsViewController.self, factory: { _ in return SettingsViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerWhoToBuildViewController(to container: Container) {
        container
            .register(WhoToBuildViewController.self, factory: { _ in return WhoToBuildViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerYourRobotsViewController(to container: Container) {
        container
            .register(YourRobotsViewController.self, factory: { _ in return YourRobotsViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerBuildRobotViewController(to container: Container) {
        container
            .register(BuildRobotViewController.self, factory: { _ in return BuildRobotViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
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
            .register(RobotConfigurationViewController.self, factory: { _ in
                return RobotConfigurationViewController()
            })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerMotorConfigViewController(to container: Container) {
        container
            .register(MotorConfigViewController.self, factory: { _ in return MotorConfigViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)
                viewController.testCodeService = resolver.resolve(PortTestCodeServiceInterface.self)
            }
            .inObjectScope(.transient)
    }

    private func registerSensorConfigViewController(to container: Container) {
        container
            .register(SensorConfigViewController.self, factory: { _ in return SensorConfigViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)
                viewController.testCodeService = resolver.resolve(PortTestCodeServiceInterface.self)
            }
            .inObjectScope(.transient)
    }

    private func registerPlayControllerViewController(to container: Container) {
        container
            .register(PlayControllerViewController.self, factory: { _ in return PlayControllerViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerFirmwareUpdateViewController(to container: Container) {
        container
            .register(FirmwareUpdateViewController.self, factory: { _ in return FirmwareUpdateViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerAboutViewController(to container: Container) {
        container
            .register(AboutViewController.self, factory: { _ in return AboutViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerControllerSelectorViewController(to container: Container) {
        container
            .register(ControllerLayoutSelectorViewController.self, factory: { _ in
                return ControllerLayoutSelectorViewController()
            })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerProgramsBottomViewController(to container: Container) {
        container
            .register(MostRecentProgramsViewController.self, factory: { _ in
                return MostRecentProgramsViewController()
            })
            .inObjectScope(.transient)
    }

    private func registerPadConfigurationViewController(to container: Container) {
        container
            .register(PadConfigurationViewController.self, factory: { _ in return PadConfigurationViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
                viewController.firebaseService = resolver.resolve(FirebaseServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerProgramSelectorViewController(to container: Container) {
        container
            .register(ProgramSelectorViewController.self, factory: { _ in
                return ProgramSelectorViewController()
            })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerDialpadViewController(to container: Container) {
        container
            .register(DialpadInputViewController.self, factory: { _ in
                return DialpadInputViewController()
            })
            .inObjectScope(.weak)
    }

    private func registerButtonlessProgramsViewController(to container: Container) {
        container
            .register(ButtonlessProgramsViewController.self, factory: { _ in
                return ButtonlessProgramsViewController()
            })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerProgramsOrderViewController(to container: Container) {
        container
            .register(ProgramPriorityViewController.self, factory: { _ in return ProgramPriorityViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
                viewController.realmService = resolver.resolve(RealmServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }

    private func registerCommunityViewController(to container: Container) {
        container
            .register(CommunityViewController.self, factory: { _ in return CommunityViewController() })
            .initCompleted { (resolver, viewController) in
                viewController.bluetoothService = resolver.resolve(BluetoothServiceInterface.self)!
            }
            .inObjectScope(.weak)
    }
}
