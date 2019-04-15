//
//  BluetoothReachability.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import CoreBluetooth

final class BluetoothReachability: NSObject {
    static let shared = BluetoothReachability()

    // MARK: - Properties
    var isBluetoothEnabled: Bool {
        return bluetoothManager.state == .poweredOn
    }
    var stateChangeHandler: ((CBManagerState) -> Void)?
    private var bluetoothManager: CBPeripheralManager!

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
