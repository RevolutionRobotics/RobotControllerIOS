//
//  FirebaseServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol FirebaseServiceInterface {
    func getRobots(completion: CallbackType<Result<[Robot], FirebaseError>>?)
}
