//
//  FirebaseServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation

protocol FirebaseServiceInterface {
    func prefetchData(onError: CallbackType<Error?>?)
    func getConnectionState() -> FirebaseService.ConnectionState
    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?)
    func getMinVersion(completion: CallbackType<Result<Version, FirebaseError>>?)
    func getChallengeCategories(completion: CallbackType<Result<[ChallengeCategory], FirebaseError>>?)
    func getFirmwareUpdate(completion: CallbackType<Result<FirmwareUpdate, FirebaseError>>?)
    func downloadFirmwareUpdate(resourceURL: String, completion: CallbackType<Result<Data, FirebaseError>>?)
    func registerDevice(named name: String)
}
