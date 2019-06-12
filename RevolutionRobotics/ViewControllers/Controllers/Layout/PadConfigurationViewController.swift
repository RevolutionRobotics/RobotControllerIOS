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

    // MARK: - ViewModel
    final class ViewModel {
        var b1: ProgramDataModel?
        var b2: ProgramDataModel?
        var b3: ProgramDataModel?
        var b4: ProgramDataModel?
        var b5: ProgramDataModel?
        var b6: ProgramDataModel?

        init(b1: ProgramDataModel?,
             b2: ProgramDataModel?,
             b3: ProgramDataModel?,
             b4: ProgramDataModel?,
             b5: ProgramDataModel?,
             b6: ProgramDataModel?) {
            self.b1 = b1
            self.b2 = b2
            self.b3 = b3
            self.b4 = b4
            self.b5 = b5
            self.b6 = b6
        }

        func programSelected(_ program: ProgramDataModel?, on buttonNumber: Int) {
            switch buttonNumber {
            case 1: b1 = program
            case 2: b2 = program
            case 3: b3 = program
            case 4: b4 = program
            case 5: b5 = program
            case 6: b6 = program
            default: break
            }
        }

        var programs: [ProgramDataModel] {
            return [b1, b2, b3, b4, b5, b6].compactMap({ $0 })
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var nextButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var controllerType: ControllerType = .gamer
    var configurationView: ConfigurableControllerView!
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var configurationId: String?

    // MARK: - Private
    private var programs: [ProgramDataModel] = []
    private var selectedButtonIndex: Int?
    private var selectedButtonState: ControllerButton.ControllerButtonState?
    private var selectedButtonProgram: ProgramDataModel?
    private let viewModel = ViewModel(b1: nil, b2: nil, b3: nil, b4: nil, b5: nil, b6: nil)
}

// MARK: - View lifecycle
extension PadConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ControllerKeys.configureTitle.translate(), delegate: self)
        setupConfigurationView()
        fetchPrograms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNextButton()

    }
}

// MARK: - Selection handling
extension PadConfigurationViewController {
    private func controllerButtonSelected(at index: Int) {
        guard let buttonState = configurationView.buttonState(of: index) else { return }

        selectedButtonIndex = index
        selectedButtonState = buttonState
        selectedButtonProgram = selectedProgram(of: buttonState)
        showMostRecentProgramSelector()
    }

    private func programSelected(_ program: ProgramDataModel?, on buttonNumber: Int) {
        if let program = program {
            configurationView.set(state: .selected(program), on: buttonNumber)
        } else {
            configurationView.set(state: .normal, on: buttonNumber)
        }

        viewModel.programSelected(program, on: buttonNumber)

        dismissModalViewController()
    }

    private func bottomBarDismissed() {
        configurationView.set(state: selectedButtonState!, on: selectedButtonIndex!)
        dismissModalViewController()
    }

    private func showMoreSelected() {
        let programSelector = AppContainer.shared.container.unwrappedResolve(ProgramSelectorViewController.self)
        programSelector.prohibitedPrograms = viewModel.programs
        programSelector.configurationVariableNames =
            realmService.getConfiguration(id: configurationId)?.mapping?.variableNames ?? []
        programSelector.programSelected = { [weak self] program in
            self?.navigationController?.popViewController(animated: true)
            self?.showProgramInfoModal(
                program: program,
                onDismissed: {
                    self?.configurationView.set(state: (self?.selectedButtonState!)!, on: (self?.selectedButtonIndex)!)
            })
        }
        programSelector.dismissedCallback = { [weak self] in
            self?.configurationView.set(state: (self?.selectedButtonState!)!, on: (self?.selectedButtonIndex)!)
        }
        dismissModalViewController()
        navigationController?.pushViewController(programSelector, animated: true)
    }
}

// MARK: - Presentation
extension PadConfigurationViewController {
    private func showMostRecentProgramSelector() {
        let programBottomBar = AppContainer.shared.container.unwrappedResolve(MostRecentProgramsViewController.self)
        var displayablePrograms: [ProgramDataModel] = []
        if let selectedProgram = selectedButtonProgram {
            let programSet = Set(programs)
            let prohibitedProgramSet = Set(viewModel.programs)
            let allowedPrograms = programSet.subtracting(prohibitedProgramSet)
            displayablePrograms = Array(allowedPrograms)
            displayablePrograms.append(selectedProgram)
        } else {
            displayablePrograms = Array(Set(programs).subtracting(Set(viewModel.programs)))
        }
        programBottomBar.setup(programs: displayablePrograms, selectedProgram: selectedButtonProgram)
        programBottomBar.programSelected = { [weak self] program in
            self?.dismissModalViewController()
            self?.showProgramInfoModal(program: program,
                                       onDismissed: { [weak self] in
                                        self?.configurationView.set(state: (self?.selectedButtonState)!,
                                                                    on: (self?.selectedButtonIndex)!)
            })
        }
        programBottomBar.dismissed = { [weak self] in
            self?.bottomBarDismissed()
        }
        programBottomBar.showMoreTapped = { [weak self] in
            self?.showMoreSelected()
            if (self?.programs)!.isEmpty {
                self?.configurationView.set(state: (self?.selectedButtonState)!, on: (self?.selectedButtonIndex)!)
            }
        }

        self.configurationView.set(state: .highlighted, on: selectedButtonIndex!)
        self.presentViewControllerModally(programBottomBar, transitionStyle: .crossDissolve)
    }

    private func showProgramInfoModal(program: ProgramDataModel, onDismissed: Callback?) {
        guard let buttonState = selectedButtonState else { return }
        let programInfoModal = ProgramInfoModal.instatiate()
        let shouldDisplayRemove = selectedProgram(of: buttonState) != nil && selectedProgram(of: buttonState) == program
        let infoType: ProgramInfoModal.InfoType = shouldDisplayRemove ? .remove : .add

        programInfoModal.configure(
            program: program,
            infoType: infoType,
            issue: nil,
            editButtonHandler: {
                print("Edit button tapped")
        },
            actionButtonHandler: { [weak self] _ in
                self?.programSelected(shouldDisplayRemove ? nil: program, on: (self?.selectedButtonIndex)!)
        })

        presentModal(with: programInfoModal, onDismissed: onDismissed)
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
        instantiateConfigurationView()
        configurationView.selectionCallback = { [weak self] index in
            self?.controllerButtonSelected(at: index)
        }
        setupConstraints()
    }

    private func instantiateConfigurationView() {
        switch controllerType {
        case .gamer:
            configurationView = GamerConfigurationView.instatiate()
        case .driver:
            configurationView = DriverConfigurationView.instatiate()
        case .multiTasker:
            configurationView = MultiTaskerConfigurationView.instatiate()
        }
    }

    private func setupConstraints() {
        configurationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(configurationView)
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

// MARK: - Fetch data
extension PadConfigurationViewController {
    private func fetchPrograms() {
        let variableNames = realmService.getConfiguration(id: configurationId)?.mapping?.variableNames ?? []
        programs = realmService.getPrograms().filter({ Set($0.variableNames).isSubset(of: variableNames) })
    }
}

extension PadConfigurationViewController {
    private func selectedProgram(of buttonState: ControllerButton.ControllerButtonState) -> ProgramDataModel? {
        guard case .selected(let program) = buttonState else { return nil }
        return program
    }
}
