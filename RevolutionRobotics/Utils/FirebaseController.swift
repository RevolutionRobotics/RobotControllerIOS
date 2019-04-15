//
//  FirebaseController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

final class FirebaseController {
    // MARK: - Constants
    private enum Constants {
        static let robot = "robot"
        static let configuration = "configuration"
        static let buildStep = "buildStep"
        static let testCode = "testCode"
    }

    // MARK: - Properties
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!

    static let shared = FirebaseController()

    // MARK: - Public functions
    public func setup() {
        setupDatabase()
        setupStorage()
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

    // MARK: - Private functions
    private func setupDatabase() {
        databaseRef = Database.database().reference()
    }

    private func setupStorage() {
        storageRef = Storage.storage().reference()
    }

    // Testing purposes
    private func getData() {
        getData(for: Constants.robot, type: Robot.self)
        getData(for: Constants.configuration, type: Configuration.self)
        getData(for: Constants.buildStep, type: BuildStep.self)
        getData(for: Constants.testCode, type: TestCode.self)
    }
}
