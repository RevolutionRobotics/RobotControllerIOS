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
    // MARK: - Constants
    private enum Constants {
        static let robot = "robot"
        static let configuration = "configuration"
        static let buildStep = "buildStep"
        static let testCode = "testCode"
    }

    // MARK: - Properties
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!

    // MARK: - Initialization
    init() {
        setup()
    }

    public func getData<T: FirebaseData>(for path: String, type: T.Type) {
        databaseRef.child(path).observeSingleEvent(of: .value) { snapshot in
            for children in snapshot.children {
                if let snap = children as? DataSnapshot {
                    if let result = type.init(snapshot: snap) {
                        print("\(result)\n")
                    }
                }
            }
        }
    }

    public func getImage(with path: String) {
        let imageRef = storageRef.child(path)
        imageRef.downloadURL { (url, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("got image at url: \(url!)")
            }
        }
    }

    // Testing purposes
    private func getData() {
        getData(for: Constants.robot, type: Robot.self)
        getData(for: Constants.configuration, type: Configuration.self)
        getData(for: Constants.buildStep, type: BuildStep.self)
        getData(for: Constants.testCode, type: TestCode.self)
    }
}

// MARK: - Setups
extension FirebaseService {
    private func setup() {
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
}

// MARK: - FirebaseServiceInterface
extension FirebaseService: FirebaseServiceInterface {
    func getRobots() -> [Robot] {
        return []
    }
}
