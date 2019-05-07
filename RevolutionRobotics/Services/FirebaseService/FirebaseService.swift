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
    private let databaseRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
}

// MARK: - FirebaseServiceInterface
extension FirebaseService: FirebaseServiceInterface {
    func getBuildSteps(for robotId: Int?, completion: CallbackType<Result<[BuildStep], FirebaseError>>?) {
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
