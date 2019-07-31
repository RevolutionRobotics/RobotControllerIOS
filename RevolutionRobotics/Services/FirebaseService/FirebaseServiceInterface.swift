//
//  FirebaseServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

protocol FirebaseServiceInterface {
    func prefetchData(onError: CallbackType<Error>?)
    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?)
    func getBuildSteps(for robotId: String?, completion: CallbackType<Result<[BuildStep], FirebaseError>>?)
    func getMinVersion(completion: CallbackType<Result<Version, FirebaseError>>?)
    func getConfigurations(completion: CallbackType<Result<[Configuration], FirebaseError>>?)
    func getConfiguration(id: String, completion: CallbackType<Result<Configuration?, FirebaseError>>?)
    func getController(for configurationId: String, completion: CallbackType<Result<Controller, FirebaseError>>?)
    func getControllers(completion: CallbackType<Result<[Controller], FirebaseError>>?)
    func getPrograms(completion: CallbackType<Result<[Program], FirebaseError>>?)
    func getPrograms(for controllerId: String, completion: CallbackType<Result<[Program?], FirebaseError>>?)
    func getChallengeCategories(completion: CallbackType<Result<[ChallengeCategory], FirebaseError>>?)
    func getFirmwareUpdate(completion: CallbackType<Result<[FirmwareUpdate], FirebaseError>>?)
    func downloadFirmwareUpdate(resourceURL: String, completion: CallbackType<Result<Data, FirebaseError>>?)
}
