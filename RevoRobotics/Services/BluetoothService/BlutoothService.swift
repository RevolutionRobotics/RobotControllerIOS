//
//  BlutoothService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RevolutionRoboticsBluetooth
import CoreBluetooth

final class BluetoothService: BluetoothServiceInterface {
    // MARK: - Constants
    enum Constants {
        static let minSoftwareRevision = FirmwareVersion(major: 0, minor: 1, patch: 957)
    }

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var connectedDevice: Device?
    var robotNeedsUpdate = false
    var isBluetoothPoweredOn: Bool {
        return discoverer.bluetoothRadioState == .poweredOn
    }
    private var mostRecentlyConnectedDevice: Device?
    private var shouldReconnect = false

    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let connector: RoboticsDeviceConnectorInterface = RoboticsDeviceConnector()
    private let deviceInfo: RoboticsDeviceServiceInterface = RoboticsDeviceService()
    private let batteryInfo: RoboticsBatteryServiceInterface = RoboticsBatteryService()
    private let liveController: RoboticsLiveControllerServiceInterface = RoboticsLiveControllerService()
    private let configuration: RoboticsConfigurationServiceInterface = RoboticsConfigurationService()

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
                guard let `self` = self else { return }
                self.getSoftwareRevision(onCompleted: { result in
                    switch result {
                    case .success(let revision):
                        if let firmwareVersion = FirmwareVersion(from: revision) {
                            self.robotNeedsUpdate = Constants.minSoftwareRevision > firmwareVersion
                        }

                        NotificationCenter.default.post(name: .robotConnected, object: nil)
                    case .failure(let error):
                        self.robotNeedsUpdate = false
                        error.report()
                        NotificationCenter.default.post(name: .robotConnectionError, object: error)
                    }
                })
                self.connectedDevice = device
                self.mostRecentlyConnectedDevice = device
                self.firebaseService.registerDevice(named: device.name)
            },
            onDisconnected: { [weak self] in
                guard let `self` = self else { return }
                NotificationCenter.default.post(name: .robotDisconnected, object: nil)
                self.connectedDevice = nil
                self.robotNeedsUpdate = false
            },
            onError: { error in
                error.report()
                NotificationCenter.default.post(name: .robotConnectionError, object: error)
                self.robotNeedsUpdate = false
        })
    }

    func reconnect() {
        guard let mostRecentlyConnectedDevice = mostRecentlyConnectedDevice, shouldReconnect else { return }
        connect(to: mostRecentlyConnectedDevice)
    }

    func disconnect(shouldReconnect: Bool) {
        guard connectedDevice != nil else { return }
        connector.disconnect()
        self.shouldReconnect = shouldReconnect
        self.robotNeedsUpdate = false
    }

    func sendConfigurationData(_ data: Data, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.sendConfiguration(
            with: data,
            onSuccess: {
                onCompleted?(.success("Success"))
        },
            onError: { error in
                error.report()
                onCompleted?(.failure(error))
        })
    }

    func setSystemId(to id: String, onCompleted: Callback?, onError: CallbackType<Error>?) {
        deviceInfo.setSystemId(id: id, onCompleted: onCompleted, onError: onError)
    }

    // MARK: - Device info
    func getPrimaryBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getPrimaryBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                                onError: { error in
                                                    error.report()
                                                    onCompleted?(.failure(error)) })
    }

    func getMotorBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getMotorBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                              onError: { error in
                                                error.report()
                                                onCompleted?(.failure(error)) })
    }

    func getSerialNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSerialNumber(onCompleted: { onCompleted?(.success($0)) },
                                   onError: { error in
                                    error.report()
                                    onCompleted?(.failure(error)) })
    }

    func getManufacturerName(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getManufacturerName(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getHardwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getHardwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { error in
                                        error.report()
                                        onCompleted?(.failure(error)) })
    }

    func getSoftwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSoftwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { error in
                                        error.report()
                                        onCompleted?(.failure(error)) })
    }

    func getFirmwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getFirmwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { error in
                                        error.report()
                                        onCompleted?(.failure(error)) })
    }

    func getSystemId(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSystemId(onCompleted: { onCompleted?(.success($0)) },
                               onError: { error in
                                error.report()
                                onCompleted?(.failure(error)) })
    }

    func getModelNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getModelNumber(onCompleted: { onCompleted?(.success($0)) },
                                  onError: { onCompleted?(.failure($0)) })
    }

    func updateFramework(data: Data, version: String, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.updateFramework(with: data,
                                      onSuccess: { onCompleted?(.success("Success")) },
                                      onError: { error in
                                        error.report()
                                        onCompleted?(.failure(error))
        })
    }

    func stopWrite() {
        configuration.stopWrite()
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

    func testKit(data: String, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.testKit(
            with: data.data(using: .utf8)!,
            onSuccess: {
                onCompleted?(.success("Success"))
        },
            onError: { error in
                error.report()
                onCompleted?(.failure(error))
        })
    }
}
