//
//  PortTestCodeServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 06. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

protocol PortTestCodeServiceInterface {
    func bumperTestCode(for portNumber: Int) -> String
    func distanceTestCode(for portNumber: Int) -> String
    func motorTestCode(for portNumber: Int, direction: Rotation?) -> String
    func drivatrainTestCode(for portNumber: Int, direction: Rotation, side: Side) -> String
}
