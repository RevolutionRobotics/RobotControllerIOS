//
//  PlayControllerViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

final class PlayControllerViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var padViewContainer: UIView!
    @IBOutlet private weak var bluetoothButton: UIButton!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var bluetoothService: BluetoothServiceInterface!
    var controllerDataModel: ControllerDataModel?
    private var padView: PlayablePadView!
    private var programs: [ProgramDataModel?] = [] {
        didSet {
            configurePadView()
        }
    }
    private var configurationAlreadySent: Bool = false
}

// MARK: View lifecycle
extension PlayControllerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: controllerDataModel?.name ?? RobotsKeys.Controllers.Play.screenTitle.translate(),
                            delegate: self)
        setupPadView()
        fetchPrograms()
        if bluetoothService.connectedDevice != nil {
            sendConfiguration()
        } else {
            bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
            presentBluetoothModal()
        }

        subscribeForConnectionChange()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bluetoothService.stopKeepalive()
        unsubscribeFromConnectionChange()
    }
}

// MARK: - Setup
extension PlayControllerViewController {
    private func setupPadView() {
        guard let typeString = controllerDataModel?.type,
            let type = ControllerType(rawValue: typeString) else {
                return
        }
        switch type {
        case .gamer:
            padView = GamerPadView.instatiate()
        case .driver:
            padView = DriverPadView.instatiate()
        case .multiTasker:
            padView = MultiTaskerPadView.instatiate()
        }

        padViewContainer.addSubview(padView)
        padView.anchorToSuperview()
    }

    private func configurePadView() {
        padView.configure(programs: programs)

        padView.xAxisPositionChanged = { [weak self] xPosition in
            self?.bluetoothService.updateXDirection(Int(xPosition.nextDown.rounded(.toNearestOrAwayFromZero)))
        }

        padView.yAxisPositionChanged = { [weak self] yPosition in
            self?.bluetoothService.updateYDirection(Int(yPosition.nextDown.rounded(.toNearestOrAwayFromZero)))
        }

        padView.buttonTapped = { [weak self] pressedPadButton in
            self?.bluetoothService.changeButtonState(index: pressedPadButton.index, pressed: pressedPadButton.pressed)
        }
    }
}

// MARK: - Data fetching
extension PlayControllerViewController {
    private func fetchPrograms() {
        let b1Program = realmService.getProgram(id: controllerDataModel?.mapping?.b1?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b1?.programId)
        let b2Program = realmService.getProgram(id: controllerDataModel?.mapping?.b2?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b2?.programId)
        let b3Program = realmService.getProgram(id: controllerDataModel?.mapping?.b3?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b3?.programId)
        let b4Program = realmService.getProgram(id: controllerDataModel?.mapping?.b4?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b4?.programId)
        let b5Program = realmService.getProgram(id: controllerDataModel?.mapping?.b5?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b5?.programId)
        let b6Program = realmService.getProgram(id: controllerDataModel?.mapping?.b6?.programId) ??
            realmService.getProgram(remoteId: controllerDataModel?.mapping?.b6?.programId)
        programs = [b1Program, b2Program, b3Program, b4Program, b5Program, b6Program]
    }
}

// MARK: - Connections
extension PlayControllerViewController {
    private func presentBluetoothModal() {
        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            startDiscoveryHandler: { [weak self] in
                self?.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure:
                        os_log("Error: Failed to discover peripherals!")
                    }
                })

            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            nextStep: nil)
    }

    private func presentDisconnectModal() {
        let view = DisconnectModal.instatiate()
        view.robotName = bluetoothService.connectedDevice?.name
        view.disconnectHandler = { [weak self] in
            self?.bluetoothService.disconnect()
            self?.dismissModalViewController()
        }
        view.cancelHandler = { [weak self] in
            self?.dismissModalViewController()
        }
        presentModal(with: view)
    }

    override func connected() {
        super.connected()
        bluetoothService.stopDiscovery()
        sendConfiguration()
    }

    override func disconnected() {
        bluetoothService.stopKeepalive()
        bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
    }

    private func sendConfiguration() {
        let data = ConfigurationJSONData(
            configuration: realmService.getConfiguration(id: controllerDataModel?.configurationId)!,
            controller: controllerDataModel!,
            programs: realmService.getPrograms())
        do {
            let encodedData = try JSONEncoder().encode(data)
            bluetoothService.sendConfigurationData(encodedData, onCompleted: { [weak self] result in
                switch result {
                case .success:
                    self?.configurationAlreadySent = true
                    self?.bluetoothService.startKeepalive()
                    self?.bluetoothButton.setImage(Image.Common.bluetoothIcon, for: .normal)
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.bluetoothService.stopKeepalive()
                    self?.bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Actions
extension PlayControllerViewController {
    @IBAction private func bluetoothButtonTapped(_ sender: Any) {
        guard bluetoothService.connectedDevice != nil else {
            presentBluetoothModal()
            return
        }

        presentDisconnectModal()
    }
}
