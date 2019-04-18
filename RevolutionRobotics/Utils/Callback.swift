//
//  Callback.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

typealias Callback = () -> Void
typealias CallbackType<T> = (T) -> Void
typealias CallbackOptionalType<T> = (T?) -> Void
