//
//  PlayControllerViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PlayControllerViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var padViewContainer: UIView!
    @IBOutlet private weak var bluetoothButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var bluetoothService: BluetoothServiceInterface!
    var controllerType: ControllerType = .gamer
    private var padView: PlayablePadView!
    private var programs: [Program] = [] {
        didSet {
            configurePadView()
        }
    }
}

// MARK: View lifecycle
extension PlayControllerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.Controllers.Play.screenTitle.translate(), delegate: self)
        setupPadView()
        fetchPrograms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribeForConnectionChange()

        if bluetoothService.hasConnectedDevice {
            bluetoothService.startKeepalive()
        } else {
            presentBluetoothModal()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bluetoothService.stopKeepalive()
        unsubscribeFromConnectionChange()
    }
}

// MARK: - Setup
extension PlayControllerViewController {
    private func setupPadView() {
        switch controllerType {
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

        padView.horizontalPositionChanged = { [weak self] xPosition in
            self?.bluetoothService.updateXDirection(Int(xPosition.rounded(.toNearestOrAwayFromZero)))
        }

        padView.verticalPositionChanged = { [weak self] yPosition in
            self?.bluetoothService.updateYDirection(Int(yPosition.rounded(.toNearestOrAwayFromZero)))
        }

        padView.buttonTapped = { [weak self] pressedPadButton in
            self?.bluetoothService.changeButtonState(index: pressedPadButton.index, pressed: pressedPadButton.pressed)
        }
    }
}

// MARK: - Data fetching
extension PlayControllerViewController {
    private func fetchPrograms() {
        firebaseService.getPrograms { [weak self] result in
            switch result {
            case .success(let programs):
                self?.programs = programs
            case .failure(let error):
                print("Error while fetching programs: \(error)")
            }
        }
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
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })

            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            nextStep: nil)
    }

    override func connected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissViewController()
        }

        bluetoothButton.setImage(Image.Common.bluetoothIcon, for: .normal)
        bluetoothService.startKeepalive()
    }

    override func disconnected() {
        bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
    }
}

// MARK: - Actions
extension PlayControllerViewController {
    @IBAction private func bluetoothButtonTapped(_ sender: Any) {
        guard !bluetoothService.hasConnectedDevice else { return }

        presentBluetoothModal()
    }

    @IBAction private func editButtonTapped(_ sender: Any) {
    }
}
