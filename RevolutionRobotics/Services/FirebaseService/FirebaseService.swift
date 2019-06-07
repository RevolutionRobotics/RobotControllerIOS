//
//  FirebaseService.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

final class FirebaseService {
    // MARK: - Properties
    private let databaseRef: DatabaseReference
    private let storageRef: StorageReference

    init() {
        Database.database().isPersistenceEnabled = true
        databaseRef = Database.database().reference()
        databaseRef.keepSynced(true)
        storageRef = Storage.storage().reference()
    }
}

// MARK: - FirebaseServiceInterface
extension FirebaseService: FirebaseServiceInterface {
    func prefetchData() {
        getRobots(completion: { [weak self] result in
            switch result {
            case .success(let robots):
                robots.forEach({ robot in
                    self?.getBuildSteps(for: robot.id, completion: nil)
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        })

        getConfigurations(completion: nil)
        getControllers(completion: nil)
        getChallengeCategories(completion: nil)
        getPrograms(completion: { result in
            switch result {
            case .success(let programs):
                let realmService = AppContainer.shared.container.unwrappedResolve(RealmServiceInterface.self)
                if realmService.getPrograms().isEmpty {
                    var dataModels: [ProgramDataModel] = []
                    programs.forEach({ program in
                        let dataModel = ProgramDataModel(program: program)
                        dataModels.append(dataModel)
                        Storage.storage().store(resourceName: program.xml, as: dataModel.xmlFileName)
                        Storage.storage().store(resourceName: program.python, as: dataModel.pythonFileName)
                    })
                    realmService.savePrograms(programs: dataModels)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    func getConfiguration(id: String, completion: CallbackType<Result<Configuration?, FirebaseError>>?) {
        getDataArray(Configuration.self, completion: { (result: Result<[Configuration], FirebaseError>) in
            switch result {
            case .success(let configurations):
                completion?(.success(configurations.first(where: { "\($0.id)" == id })))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func getConfigurations(completion: CallbackType<Result<[Configuration], FirebaseError>>?) {
        getDataArray(Configuration.self, completion: completion)
    }

    func getBuildSteps(for robotId: String?, completion: CallbackType<Result<[BuildStep], FirebaseError>>?) {
        guard robotId != nil else {
            completion?(.failure(FirebaseError.invalidRobotId))
            return
        }

        getDataArray(BuildStep.self, completion: { (result: Result<[BuildStep], FirebaseError>) in
            switch result {
            case .success(let steps):
                completion?(.success(steps.filter({ $0.robotId == robotId })))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?) {
        getDataArray(Robot.self, completion: completion)
    }

    func getController(for configurationId: String, completion: CallbackType<Result<Controller, FirebaseError>>?) {
        getConfiguration(id: configurationId, completion: { [weak self] result in
            switch result {
            case .success(let configuration):
                guard let configuration = configuration else {
                    completion?(.failure(FirebaseError.invalidRobotId))
                    return
                }

                self?.getControllers(completion: { result in
                    switch result {
                    case .success(let controllers):
                        completion?(.success(controllers.first(where: { $0.id == configuration.controller })!))
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    func getControllers(completion: CallbackType<Result<[Controller], FirebaseError>>?) {
        getDataArray(Controller.self, completion: completion)
    }

    func getPrograms(completion: CallbackType<Result<[Program], FirebaseError>>?) {
        getDataArray(Program.self, completion: completion)
    }

    func getPrograms(for controllerId: String, completion: CallbackType<Result<[Program?], FirebaseError>>?) {
        getDataArray(Controller.self, completion: { [weak self] (result: Result<[Controller], FirebaseError>) in
            switch result {
            case .success(let controllers):
                let selectedController = controllers.first(where: { $0.id == controllerId })!

                self?.getDataArray(Program.self, completion: { (result: Result<[Program], FirebaseError>) in
                    switch result {
                    case .success(let programs):
                        let programs = selectedController.mapping.programIds.map({ id -> Program? in
                            guard let id = id else { return nil }
                            return programs.first(where: { $0.id == id })
                        })
                        completion?(.success(programs))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                completion?(.failure(error))
            }
        })

    }

    func getChallengeCategories(completion: CallbackType<Result<[ChallengeCategory], FirebaseError>>?) {
        getDataArray(ChallengeCategory.self, completion: completion)
    }
}

// MARK: - Private
extension FirebaseService {
    private func getData<T: FirebaseData>(_ type: T.Type, completion: CallbackType<Result<T, FirebaseError>>?) {
        databaseRef.child(type.firebasePath).observeSingleEvent(of: .value) { snapshot in
            guard let data = T(snapshot: snapshot) else {
                completion?(.failure(FirebaseError.decodeFailed("Failed to decode \(T.self) object")))
                return
            }

            completion?(.success(data))
        }
    }

    private func getDataArray<T: FirebaseData>(_ type: T.Type, completion: CallbackType<Result<[T], FirebaseError>>?) {
        databaseRef.child(type.firebasePath).observeSingleEvent(of: .value) { snapshot in
            let models = snapshot.children.compactMap { $0 as? DataSnapshot }.map(T.init)
            guard models.contains(where: { $0 != nil }) else {
                completion?(.failure(FirebaseError.arrayDecodeFailed("Failed to decode array of \(T.self)")))
                return
            }

            completion?(.success(models.compactMap { $0 }))
        }
    }
}
