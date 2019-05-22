//
//  MotorDataModel.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RealmSwift

final class MotorDataModel: Object {
    // MARK: - Constants
    enum Constants {
        static let drivetrain = "drivetrain"
        static let motor = "motor"
    }

    // MARK: - Properties
    @objc dynamic var variableName: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var testCodeId: Int = 0
    @objc dynamic var rotation: String?
    @objc dynamic var side: String?

    // MARK: - Initialization
    convenience init(variableName: String,
                     type: String,
                     testCodeId: Int,
                     rotation: String?,
                     side: String?) {
        self.init()
        self.variableName = variableName
        self.type = type
        self.testCodeId = testCodeId
        self.rotation = rotation
        self.side = side
    }

    convenience init?(remoteMotor: Motor?) {
        guard let remoteMotor = remoteMotor else { return nil }
        self.init()
        self.variableName = remoteMotor.variableName
        self.type = remoteMotor.type
        self.testCodeId = remoteMotor.testCodeId
        self.rotation = remoteMotor.rotation.rawValue
        self.side = remoteMotor.side?.rawValue
    }

    convenience init?(inMemoryMotor: InMemoryMotorDataModel?) {
        guard let inMemoryMotor = inMemoryMotor else { return nil }
        self.init()
        self.variableName = inMemoryMotor.variableName
        self.type = inMemoryMotor.type
        self.testCodeId = inMemoryMotor.testCodeId
        self.rotation = inMemoryMotor.rotation?.rawValue
        self.side = inMemoryMotor.side?.rawValue
    }
}
