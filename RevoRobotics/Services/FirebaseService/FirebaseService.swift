//
//  FirebaseService.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

final class FirebaseService {
    // MARK: - Constants
    enum Constants {
        static let deviceNameKey = "robot_id"
    }

    // MARK: - Connection state
    enum ConnectionState {
        case online, offline
    }

    // MARK: - Properties
    private let storageRef: StorageReference
    private let decoder = JSONDecoder()
    private let apiFetchHelper = ApiFetchHelper()

    private var connectionState: ConnectionState = .offline
    private var jsonData: JSON?

    init() {
        storageRef = Storage.storage().reference()
    }
}

// MARK: - FirebaseServiceInterface
extension FirebaseService: FirebaseServiceInterface {
    func prefetchData(onError: CallbackType<Error>?) {
        let userDefaults = UserDefaults.standard
        let jsonKey = UserDefaults.Keys.jsonCache

        if let json = userDefaults.string(forKey: jsonKey) {
            jsonData = JSON(parseJSON: json)
            parseData(onError: onError)
        }

        apiFetchHelper.fetchAll(callback: { [weak self] result in
            guard let `self` = self else { return }
            self.connectionState = .online
            self.jsonData = result
            self.parseData(onError: onError)
        })
    }

    func parseData(onError: CallbackType<Error>?) {
        getMinVersion(completion: nil)
        getRobots(completion: { [weak self] result in
            switch result {
            case .success(let robots):
                robots.forEach({ robot in
                    self?.getBuildSteps(for: robot.id, completion: nil)
                })
            case .failure(let error):
                error.report()
                onError?(error)
            }
        })

        getConfigurations(completion: nil)
        getControllers(completion: nil)
        getChallengeCategories(completion: nil)
    }

    func getConnectionState() -> ConnectionState {
        return connectionState
    }

    func getMinVersion(completion: CallbackType<Result<Version, FirebaseError>>?) {
        getData("minVersion", type: Version.self, completion: completion)
    }

    func getConfiguration(id: String, completion: CallbackType<Result<Configuration?, FirebaseError>>?) {
        getDataArray("configuration",
                     type: Configuration.self,
                     completion: { (result: Result<[Configuration], FirebaseError>) in
            switch result {
            case .success(let configurations):
                completion?(.success(configurations.first(where: { "\($0.id)" == id })))
            case .failure(let error):
                error.report()
                completion?(.failure(error))
            }
        })
    }

    func getConfigurations(completion: CallbackType<Result<[Configuration], FirebaseError>>?) {
        getDataArray("configuration", type: Configuration.self, completion: completion)
    }

    func getBuildSteps(for robotId: String?, completion: CallbackType<Result<[BuildStep], FirebaseError>>?) {
        guard robotId != nil else {
            completion?(.failure(FirebaseError.invalidRobotId))
            return
        }

        getDataArray("buildStep", type: BuildStep.self, completion: { (result: Result<[BuildStep], FirebaseError>) in
            switch result {
            case .success(let steps):
                completion?(.success(steps.filter({ $0.robotId == robotId })))
            case .failure(let error):
                error.report()
                completion?(.failure(error))
            }
        })
    }

    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?) {
        getDataArray("robot", type: Robot.self, completion: completion)
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
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                error.report()
                completion?(.failure(error))
            }
        })
    }

    func getControllers(completion: CallbackType<Result<[Controller], FirebaseError>>?) {
        getDataArray("controller", type: Controller.self, completion: completion)
    }

    func getPrograms(completion: CallbackType<Result<[Program], FirebaseError>>?) {
        getDataArray("program", type: Program.self, completion: completion)
    }

    func getPrograms(for controllerId: String, completion: CallbackType<Result<[Program?], FirebaseError>>?) {
        getDataArray("controller",
                     type: Controller.self,
                     completion: { [weak self] (result: Result<[Controller], FirebaseError>) in
            switch result {
            case .success(let controllers):
                let selectedController = controllers.first(where: { $0.id == controllerId })!

                self?.getDataArray("program",
                                   type: Program.self,
                                   completion: { (result: Result<[Program], FirebaseError>) in
                    switch result {
                    case .success(let programs):
                        let programs = selectedController.mapping?.programIds().map({ id -> Program? in
                            guard let id = id else { return nil }
                            return programs.first(where: { $0.id == id })
                        })
                        completion?(.success(programs ?? []))
                    case .failure(let error):
                        error.report()
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                error.report()
                completion?(.failure(error))
            }
        })
    }

    func getRobotPrograms(for robotRemoteId: String, completion: CallbackType<Result<[Program?], FirebaseError>>?) {
        getDataArray("program", type: Program.self, completion: { (result: Result<[Program], FirebaseError>) in
            switch result {
            case .success(let programs):
                let programs = programs.filter({ $0.robotId == robotRemoteId })
                completion?(.success(programs))
            case .failure(let error):
                error.report()
                completion?(.failure(error))
            }
        })
    }

    func getChallengeCategories(completion: CallbackType<Result<[ChallengeCategory], FirebaseError>>?) {
        getDataArray("challengeCategory", type: ChallengeCategory.self, completion: completion)
    }

    func getFirmwareUpdate(completion: CallbackType<Result<[FirmwareUpdate], FirebaseError>>?) {
        getDataArray("firmware", type: FirmwareUpdate.self, completion: completion)
    }

    func downloadFirmwareUpdate(resourceURL: String, completion: CallbackType<Result<Data, FirebaseError>>?) {
        Storage.storage().reference(forURL: resourceURL).downloadURL(completion: { (url, error) in
            guard error == nil, let url = url else {
                error?.report()
                return
            }
            do {
                let data = try Data(contentsOf: url)
                completion?(.success(data))
            } catch {
                completion?(.failure(.invalidImageURL))
            }
        })
    }

    func registerDevice(named name: String) {
        Analytics.setUserProperty(name, forName: Constants.deviceNameKey)
        Analytics.logEvent("register_robot", parameters: nil)
    }
}

// MARK: - Private
extension FirebaseService {
    private func getData<T: Decodable>(
        _ key: String,
        type: T.Type,
        completion: CallbackType<Result<T, FirebaseError>>?) {
        do {
            if let data = try jsonData?[key].rawData() {
                let object = try decoder.decode(T.self, from: data)
                completion?(.success(object))
            }
        } catch {
            completion?(.failure(
                FirebaseError.decodeFailed("Failed to decode type \(T.self): \(error.localizedDescription)")))
        }
    }

    private func getDataArray<T: Decodable>
        (_ key: String, type: T.Type, completion: CallbackType<Result<[T], FirebaseError>>?) {
        let listKeys = jsonData?[key].dictionary?.keys
        do {
            let models: [T]? = try listKeys?.compactMap({ itemKey in
                guard let data = try jsonData?[key][itemKey].rawData() else {
                    return nil
                }

                return try decoder.decode(T.self, from: data)
            })

            guard
                let orderableModels = models as? [FirebaseOrderable],
                let ordered = orderableModels.sorted(by: {
                    $0.order < $1.order }) as? [T]
            else {
                completion?(.success(models ?? []))
                return
            }

            completion?(.success(ordered))
        } catch {
            handle(error: error, completion: completion)
        }
    }

    private func handle<T: Decodable>(
        error: Error,
        completion: CallbackType<Result<[T], FirebaseError>>?) {

        switch error {
        case DecodingError.dataCorrupted(let context):
            print(context)
        case DecodingError.keyNotFound(let key, let context):
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case DecodingError.valueNotFound(let value, let context):
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        case DecodingError.typeMismatch(let type, let context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        default:
            print("error: ", error)
        }

        error.report()
        completion?(.failure(
            FirebaseError.arrayDecodeFailed("Failed to decode type [\(T.self)]: \(error.localizedDescription)")))
    }
}
