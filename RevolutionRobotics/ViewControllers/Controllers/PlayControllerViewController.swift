//
//  PlayControllerViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBluetooth

final class PlayControllerViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var padViewContainer: UIView!

    // MARK: - Private
    private let liveService: RoboticsLiveControllerServiceInterface = RoboticsLiveControllerService()
    private var padView: PlayablePadView!
    private var programs: [Program] = [] {
        didSet {
            configurePadView()
        }
    }

    // MARK: - Public
    var firebaseService: FirebaseServiceInterface!
    var controllerType: ControllerType = .gamer
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
        liveService.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        liveService.stop()
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
            self?.liveService.updateXDirection(x: Int(xPosition.rounded(.toNearestOrAwayFromZero)))
        }

        padView.verticalPositionChanged = { [weak self] yPosition in
            self?.liveService.updateYDirection(y: Int(yPosition.rounded(.toNearestOrAwayFromZero)))
        }

        padView.buttonTapped = { [weak self] pressedPadButton in
            self?.liveService.changeButtonState(index: pressedPadButton.index, pressed: pressedPadButton.pressed)
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
