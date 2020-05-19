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

protocol BluetoothServiceInterface: class {
    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface! { get set }
    var connectedDevice: Device? { get set }
    var isBluetoothPoweredOn: Bool { get }

    // MARK: - Discovery
    func startDiscovery(onScanResult: CallbackType<Result<[Device], Error>>?)
    func stopDiscovery()

    // MARK: - Connection
    func connect(to device: Device)
    func reconnect()
    func disconnect(shouldReconnect: Bool)

    // MARK: - Device info
    func getPrimaryBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?)
    func getMotorBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?)
    func getSerialNumber(onCompleted: CallbackType<Result<String, Error>>?)
    func getManufacturerName(onCompleted: CallbackType<Result<String, Error>>?)
    func getHardwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getSoftwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getFirmwareRevision(onCompleted: CallbackType<Result<String, Error>>?)
    func getSystemId(onCompleted: CallbackType<Result<String, Error>>?)
    func setSystemId(to id: String, onCompleted: Callback?, onError: CallbackType<Error>?)
    func getModelNumber(onCompleted: CallbackType<Result<String, Error>>?)
    func sendConfigurationData(_ data: Data, onCompleted: CallbackType<Result<String, Error>>?)
    func testKit(data: String, onCompleted: CallbackType<Result<String, Error>>?)
    func updateFramework(data: Data, version: String, onCompleted: CallbackType<Result<String, Error>>?)
    func stopWrite()

    // MARK: - Live controller
    func startKeepalive()
    func stopKeepalive()
    func updateXDirection(_ xDirection: Int)
    func updateYDirection(_ yDirection: Int)
    func changeButtonState(index: Int, pressed: Bool)
}
