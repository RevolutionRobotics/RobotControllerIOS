//
//  BluetoothReachability.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import CoreBluetooth

final class BluetoothReachability: NSObject {
    // MARK: - Properties
    static let shared = BluetoothReachability()

    var isBluetoothEnabled: Bool {
        return bluetoothManager.state == .poweredOn
    }

    private var bluetoothManager: CBPeripheralManager!
    private var stateChangeHandler: ((CBManagerState) -> Void)?

    // MARK: - Initialization
    private override init() {
        super.init()
        bluetoothManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothReachability: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        stateChangeHandler?(peripheral.state)
    }
}
