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
import Alamofire

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
    private let decoder = JSONDecoder()
    private let apiFetchHandler = ApiFetchHandler()

    private var connectionState: ConnectionState = .offline
    private var jsonData: [String: JSON]?
}

// MARK: - FirebaseServiceInterface
extension FirebaseService: FirebaseServiceInterface {
    func prefetchData(onError: CallbackType<Error?>?) {
        apiFetchHandler.fetchAll(callback: { [weak self] result in
            guard let `self` = self else { return }
            self.connectionState = .online
            self.jsonData = result
            self.parseData(onError: onError)
        })
    }

    func parseData(onError: CallbackType<Error?>?) {
        getMinVersion(completion: nil)
        getRobots(completion: { result in
            switch result {
            case .success:
                onError?(nil)
            case .failure(let error):
                print(error)
                onError?(error)
            }
        })

        getChallengeCategories(completion: nil)
    }

    func getConnectionState() -> ConnectionState {
        return connectionState
    }

    func getMinVersion(completion: CallbackType<Result<Version, FirebaseError>>?) {
        getData("versionData", type: Version.self, completion: completion)
    }

    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?) {
        getDataArray("robots", type: Robot.self, completion: completion)
    }

    func getChallengeCategories(completion: CallbackType<Result<[ChallengeCategory], FirebaseError>>?) {
        getDataArray("challenges", type: ChallengeCategory.self, completion: completion)
    }

    func getFirmwareUpdate(completion: CallbackType<Result<FirmwareUpdate, FirebaseError>>?) {
        getData("firmware", type: FirmwareUpdate.self, completion: completion)
    }

    func downloadFirmwareUpdate(resourceURL: String, completion: CallbackType<Result<Data, FirebaseError>>?) {
        guard let url = URL(string: resourceURL) else {
            completion?(.failure(.firmwareDownloadFailed("Invalid firmware download URL")))
            return
        }

        let request = AF.request(url)
        request.responseData(completionHandler: { response in
            switch response.result {
            case .success(let data):
                completion?(.success(data))
            case .failure(let error):
                error.report()
                completion?(.failure(
                    .firmwareDownloadFailed("Firmware download failed: \(error.localizedDescription)")))
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
            if let data = try jsonData?[key]?.rawData() {
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
        let listItems = jsonData?[key]?.array

        do {
            let models: [T]? = try listItems?.compactMap({ item in
                let data = try item.rawData()
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
        } catch let error {
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
