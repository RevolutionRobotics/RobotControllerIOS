//
//  BluetoothServiceInterface.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import struct RevolutionRoboticsBluetooth.Device

extension Notification.Name {
    static let robotConnected = Notification.Name("robotConnected")
    static let robotDisconnected = Notification.Name("robotDisconnected")
    static let robotConnectionError = Notification.Name("robotConnectionError")
}

protocol BluetoothServiceInterface {
    // MARK: - Properties
    var hasConnectedDevice: Bool { get set }

    // MARK: - Discovery
    func startDiscovery(onScanResult: CallbackType<Result<[Device], Error>>?)
    func stopDiscovery()

    // MARK: - Connection
    func connect(to device: Device)

    // MARK: - Device info
    func getPrimaryBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?)
    func getMotorBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?)
    func getSerialNumber(onCompleted: CallbackType<Result<String, Error>>?)
    func getManufacturerName(onCompleted: CallbackType<Result<String, Error>>?)
    func getHardwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getSoftwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getFirmwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getSystemId(onCompleted: CallbackType<Result<String, Error>>?)
    func getModelNumber(onCompleted: CallbackType<Result<String, Error>>?)

    // MARK: - Live controller
    func startKeepalive()
    func stopKeepalive()
    func updateXDirection(_ xDirection: Int)
    func updateYDirection(_ yDirection: Int)
    func changeButtonState(index: Int, pressed: Bool)
}
