//
//  BlutoothService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RevolutionRoboticsBluetooth

final class BluetoothService: BluetoothServiceInterface {
    // MARK: - Properties
    var hasConnectedDevice: Bool = false
    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let connector: RoboticsDeviceConnectorInterface = RoboticsDeviceConnector()
    private let deviceInfo: RoboticsDeviceServiceInterface = RoboticsDeviceService()
    private let batteryInfo: RoboticsBatteryServiceInterface = RoboticsBatteryService()
    private let liveController: RoboticsLiveControllerServiceInterface = RoboticsLiveControllerService()

    // MARK: - Discovery
    func startDiscovery(onScanResult: CallbackType<Result<[Device], Error>>?) {
        discoverer.discoverRobots(onScanResult: { onScanResult?(.success($0)) },
                                  onError: { onScanResult?(.failure($0)) })
    }

    func stopDiscovery() {
        discoverer.stopDiscover()
    }

    // MARK: - Connection
    func connect(to device: Device) {
        connector.connect(
            to: device,
            onConnected: { [weak self] in
                NotificationCenter.default.post(name: .robotConnected, object: nil)
                self?.hasConnectedDevice = true
            },
            onDisconnected: { [weak self] in
                NotificationCenter.default.post(name: .robotDisconnected, object: nil)
                self?.hasConnectedDevice = false
            },
            onError: { error in
                NotificationCenter.default.post(name: .robotConnectionError, object: error)
        })
    }

    // MARK: - Device info
    func getPrimaryBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getPrimaryBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                                onError: { onCompleted?(.failure($0)) })
    }

    func getMotorBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getMotorBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                              onError: { onCompleted?(.failure($0)) })
    }

    func getSerialNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSerialNumber(onCompleted: { onCompleted?(.success($0)) },
                                   onError: { onCompleted?(.failure($0)) })
    }

    func getManufacturerName(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getManufacturerName(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getHardwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getHardwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getSoftwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSoftwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getFirmwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getFirmwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getSystemId(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSystemId(onCompleted: { onCompleted?(.success($0)) },
                               onError: { onCompleted?(.failure($0)) })
    }

    func getModelNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getModelNumber(onCompleted: { onCompleted?(.success($0)) },
                                  onError: { onCompleted?(.failure($0)) })
    }

    // MARK: - Live controller
    func startKeepalive() {
        liveController.start()
    }

    func stopKeepalive() {
        liveController.stop()
    }

    func updateXDirection(_ xDirection: Int) {
        liveController.updateXDirection(x: xDirection)
    }

    func updateYDirection(_ yDirection: Int) {
        liveController.updateYDirection(y: yDirection)
    }

    func changeButtonState(index: Int, pressed: Bool) {
        liveController.changeButtonState(index: index, pressed: pressed)
    }
}
