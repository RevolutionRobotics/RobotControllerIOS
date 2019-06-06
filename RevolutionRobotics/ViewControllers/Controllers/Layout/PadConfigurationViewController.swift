//
//  PadConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

final class PadConfigurationViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let nextButtonFont = Font.barlow(size: 14.0, weight: .medium)
        static let widthVisualFormat = "H:[configurationView(392)]"
        static let heightVisualFormat = "V:[configurationView(176)]"
        static let configurationView = "configurationView"
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var nextButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var controllerType: ControllerType = .gamer
    var configurationView: ConfigurableControllerView!
    var firebaseService: FirebaseServiceInterface!

    // MARK: - Private
    private var programs: [Program] = []
}

// MARK: - View lifecycle
extension PadConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.configureTitle.translate(), delegate: self)
        setupConfigurationView()
        fetchPrograms()
        handleButtonTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNextButton()
    }
}

// MARK: - Setups
extension PadConfigurationViewController {
    private func setupNextButton() {
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        nextButton.titleLabel?.font = Constants.nextButtonFont
        nextButton.setBorder(strokeColor: .white)
    }

    private func setupConfigurationView() {
        switch controllerType {
        case .gamer:
            configurationView = GamerConfigurationView.instatiate()
        case .driver:
            configurationView = DriverConfigurationView.instatiate()
        case .multiTasker:
            configurationView = MultiTaskerConfigurationView.instatiate()
        }

        configurationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(configurationView)
        setupConstraints()
    }

    private func setupConstraints() {
        let height = NSLayoutConstraint.constraints(
            withVisualFormat: Constants.heightVisualFormat,
            options: [],
            metrics: nil,
            views: [Constants.configurationView: configurationView!])
        let width = NSLayoutConstraint.constraints(
            withVisualFormat: Constants.widthVisualFormat,
            options: [],
            metrics: nil,
            views: [Constants.configurationView: configurationView!])
        let centerX = NSLayoutConstraint(item: containerView!,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: configurationView,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0.0)
        let centerY = NSLayoutConstraint(item: containerView!,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: configurationView,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0.0)
        containerView.addConstraints([centerY, centerX])
        configurationView.addConstraints(width + height)
    }
}

// MARK: - Fetch
extension PadConfigurationViewController {
    // TODO: Fetch only configuration related programs
    private func fetchPrograms() {
        firebaseService.getPrograms { (result) in
            switch result {
            case .success(let programs):
                self.programs = programs
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Handle
extension PadConfigurationViewController {
    private func handleButtonTap() {
        configurationView.selectionCallback = { [weak self] buttonNumber in
            guard let self = self else { return }
            guard let buttonState = self.configurationView.buttonState(of: buttonNumber) else { return }

            let programBottomBar = AppContainer.shared.container.unwrappedResolve(ProgramBottomBarViewController.self)
            programBottomBar.setup(programs: self.programs, selectedProgram: self.selectedProgram(of: buttonState))

            programBottomBar.programSelected = { program in
                self.showProgramInfoModal(program: program, on: buttonNumber, with: buttonState)
            }

            programBottomBar.dismissed = {
                self.handleBottomBarDismiss(on: buttonNumber, buttonState: buttonState)
            }

            programBottomBar.showMoreTapped = {
                self.handleBottomBarDismiss(on: buttonNumber, buttonState: buttonState)
                self.handleShowMore(on: buttonNumber)
            }

            self.configurationView.set(state: .highlighted, on: buttonNumber)
            self.presentViewControllerModally(programBottomBar, transitionStyle: .crossDissolve)
        }
    }

    private func showProgramInfoModal(
        program: Program,
        on buttonNumber: Int,
        with buttonState: ControllerButton.ControllerButtonState) {
        dismissViewController()
        let programInfoModal = ProgramInfoModal.instatiate()

        let infoType: ProgramInfoModal.InfoType =
            selectedProgram(of: buttonState) != nil && selectedProgram(of: buttonState) == program
                ? .remove
                : .add

        programInfoModal.configure(
            program: program,
            infoType: infoType,
            issue: nil,
            editButtonHandler: {
                print("Edit button tapped")
        },
            actionButtonHandler: { [weak self] infoType in
                self?.handleProgramSelection(
                    program: program,
                    on: buttonNumber,
                    with: infoType == .add ? .selected(program) : .normal
                )
        })

        presentModal(with: programInfoModal)
    }

    private func handleProgramSelection(
        program: Program,
        on buttonNumber: Int,
        with buttonState: ControllerButton.ControllerButtonState
    ) {
        configurationView.set(state: buttonState, on: buttonNumber)
        dismissViewController()
    }

    private func handleBottomBarDismiss(on buttonNumber: Int, buttonState: ControllerButton.ControllerButtonState) {
        configurationView.set(state: buttonState, on: buttonNumber)
        dismissViewController()
    }

    private func handleShowMore(on buttonNumber: Int) {
        let programSelector = AppContainer.shared.container.unwrappedResolve(ProgramSelectorViewController.self)
        programSelector.programSelected = { [weak self] program in
            self?.handleProgramSelection(program: program, on: buttonNumber, with: .selected(program))
        }
        presentViewControllerModally(programSelector)
    }

    private func selectedProgram(of buttonState: ControllerButton.ControllerButtonState) -> Program? {
        guard case .selected(let program) = buttonState else { return nil }
        return program
    }
}
