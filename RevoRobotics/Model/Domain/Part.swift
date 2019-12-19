//
//  Part.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

struct Part: Decodable, FirebaseOrderable {
    let name: LocalizedText
    let image: String
    var order: Int
}
