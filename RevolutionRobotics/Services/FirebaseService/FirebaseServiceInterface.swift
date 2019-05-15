//
//  FirebaseServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol FirebaseServiceInterface {
    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?)
    func getBuildSteps(for robotId: Int?, completion: CallbackType<Result<[BuildStep], FirebaseError>>?)
    func getConfigurations(completion: CallbackType<Result<[Configuration], FirebaseError>>?)
    func getControllers(completion: CallbackType<Result<[Controller], FirebaseError>>?)
    func getPrograms(completion: CallbackType<Result<[Program], FirebaseError>>?)
    func getChallengeCategory(completion: CallbackType<Result<ChallengeCategory, FirebaseError>>?)
}
