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

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var controllerDataModel: ControllerDataModel?
    var robotName: String?
    var startTime: Date?
    var onboardingInProgress = false

    private var padView: PlayablePadView!
    private var programs: [ProgramDataModel?] = [] {
        didSet {
            configurePadView()
        }
    }
    private var configurationAlreadySent: Bool = false

    override func backButtonDidTap() {
        guard onboardingInProgress else {
            super.backButtonDidTap()
            return
        }

        guard let menu = navigationController?.viewControllers
            .first(where: { $0 is MenuViewController }) as? MenuViewController
        else { return }

        menu.onboardingInProgress = true
        self.navigationController?.popToViewController(menu, animated: true)
    }
}

// MARK: View lifecycle
extension PlayControllerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: robotName ?? RobotsKeys.Controllers.Play.screenTitle.translate(),
                            delegate: self)
        setupPadView()
        fetchPrograms()
        if bluetoothService.connectedDevice != nil {
            navigationBar.bluetoothButtonState = .connected
            sendConfiguration()
        } else {
            navigationBar.bluetoothButtonState = .notConnected
            presentBluetoothModal()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false

        if let startTime = startTime, onboardingInProgress {
            let duration = round(Date().timeIntervalSince(startTime))
            logEvent(named: "drive_basic_robot", params: [
                "duration": duration
            ])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if onboardingInProgress {
            startTime = Date()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bluetoothService.stopKeepalive()
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
        case .new:
            return
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
            self?.bluetoothService.updateXDirection(Int(xPosition.nextDown.rounded(.down)))
        } 

        padView.yAxisPositionChanged = { [weak self] yPosition in
            self?.bluetoothService.updateYDirection(Int(yPosition.nextDown.rounded(.toNearestOrAwayFromZero)))
        }

        padView.buttonTapped = { [weak self] pressedPadButton in
            self?.bluetoothService.changeButtonState(index: pressedPadButton.index)
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

// MARK: - Configuration sending
extension PlayControllerViewController {
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
                    self?.navigationBar.bluetoothButtonState = .connected
                case .failure:
                    os_log("Error while sending configuration to the robot!")
                    self?.bluetoothService.stopKeepalive()
                    self?.navigationBar.bluetoothButtonState = .notConnected
                }
            })
        } catch {
            os_log("Error while encoding the configuration!")
        }
    }
}

// MARK: - Bluetooth connection
extension PlayControllerViewController {
    private func presentBluetoothModal() {
        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            isBluetoothPoweredOn: bluetoothService.isBluetoothPoweredOn,
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
            onDismissed: { [weak self] in
                self?.bluetoothService.stopDiscovery()
        })
    }

    private func presentDisconnectModal() {
        let view = DisconnectModalView.instatiate()
        view.robotName = bluetoothService.connectedDevice?.name
        view.disconnectHandler = { [weak self] in
            self?.bluetoothService.disconnect(shouldReconnect: false)
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
        navigationBar.bluetoothButtonState = .connected
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            self?.sendConfiguration()
        }
    }

    override func disconnected() {
        bluetoothService.stopKeepalive()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
