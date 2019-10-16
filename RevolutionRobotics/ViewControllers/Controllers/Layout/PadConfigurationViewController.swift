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
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var controllerType: ControllerType? {
        didSet {
            guard oldValue != nil else { return }
            refreshViewState()
        }
    }
    var configurationView: ConfigurableControllerView!
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var configurationId: String?
    var selectedControllerId: String?

    private var programs: [ProgramDataModel] = []
    private var selectedButtonIndex: Int?
    private var selectedButtonState: ControllerButton.ControllerButtonState?
    private var selectedButtonProgram: ProgramDataModel?
    private var selectedController: ControllerDataModel? {
        didSet {
            if let selectedController = selectedController {
                self.controllerType = ControllerType(rawValue: selectedController.type)
            }
        }
    }
    let viewModel = ControllerViewModel()
}

// MARK: - View lifecycle
extension PadConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSelectedController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPrograms()
        setupViewModel()
        configurationView.removeFromSuperview()
        refreshViewState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let buttonIndex = selectedButtonIndex, let buttonState = selectedButtonState else { return }
        configurationView.set(state: buttonState, on: buttonIndex)
    }
}

// MARK: - Prefill data
extension PadConfigurationViewController {
    //swiftlint:disable cyclomatic_complexity
    private func prefillData() {
        guard let selectedController = selectedController, let mapping = selectedController.mapping else { return }

        if let binding = mapping.b1 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b1Binding = binding
                viewModel.b1Program = program
                configurationView.set(state: .selected(program), on: 1)
            }
        }
        if let binding = mapping.b2 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b2Binding = binding
                viewModel.b2Program = program
                configurationView.set(state: .selected(program), on: 2)
            }
        }
        if let binding = mapping.b3 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b3Binding = binding
                viewModel.b3Program = program
                configurationView.set(state: .selected(program), on: 3)
            }
        }
        if let binding = mapping.b4 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b4Binding = binding
                viewModel.b4Program = program
                configurationView.set(state: .selected(program), on: 4)
            }
        }
        if let binding = mapping.b5 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b5Binding = binding
                viewModel.b5Program = program
                configurationView.set(state: .selected(program), on: 5)
            }
        }
        if let binding = mapping.b6 {
            if let program = realmService.getProgram(id: binding.programId) ??
                realmService.getProgram(remoteId: binding.programId) {
                viewModel.b6Binding = binding
                viewModel.b6Program = program
                configurationView.set(state: .selected(program), on: 6)
            }
        }

        viewModel.backgroundProgramBindings = Array(selectedController.backgroundProgramBindings)
        viewModel.backgroundPrograms = selectedController.backgroundProgramBindings
                .compactMap { [weak self] binding in
                    self?.realmService.getProgram(id: binding.programId) ??
                        self?.realmService.getProgram(remoteId: binding.programId)
                }
    }

    func refreshViewState() {
        setupConfigurationView()
        prefillData()
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
        guard let selectedController = selectedController else { return }

        if let program = program {
            configurationView.set(state: .selected(program), on: buttonNumber)
        } else {
            configurationView.set(state: .normal, on: buttonNumber)
        }

        viewModel.programSelected(program, on: buttonNumber)
        realmService.updateObject(closure: { [weak self] in
            guard let `self` = self else { return }

            selectedController.lastModified = Date()
            switch buttonNumber {
            case 1:
                selectedController.mapping?.b1 = self.viewModel.b1Binding
            case 2:
                selectedController.mapping?.b2 = self.viewModel.b2Binding
            case 3:
                selectedController.mapping?.b3 = self.viewModel.b3Binding
            case 4:
                selectedController.mapping?.b4 = self.viewModel.b4Binding
            case 5:
                selectedController.mapping?.b5 = self.viewModel.b5Binding
            case 6:
                selectedController.mapping?.b6 = self.viewModel.b6Binding
            default:
                break
            }
        })

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
    private func isProgramCompatible(_ program: ProgramDataModel) -> Bool {
        guard let variableNames = realmService.getConfiguration(id: configurationId)?.mapping?.variableNames else {
            return false
        }
        if variableNames.isEmpty {
            return true
        }
        return Set(program.variableNames).isSubset(of: Set(variableNames))
    }

    private func showMostRecentProgramSelector() {
        let programBottomBar = AppContainer.shared.container.unwrappedResolve(MostRecentProgramsViewController.self)
        var displayablePrograms: [ProgramDataModel] = []
        if let selectedProgram = selectedButtonProgram {
            let programSet = Set(programs)
            let prohibitedProgramSet = Set(viewModel.programs)
            let allowedPrograms = programSet.subtracting(prohibitedProgramSet)
            displayablePrograms = Array(allowedPrograms).filter(isProgramCompatible)
            displayablePrograms.insert(selectedProgram, at: 0)
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
        let programInfoModal = ProgramInfoModalView.instatiate()
        let shouldDisplayRemove = selectedProgram(of: buttonState) != nil && selectedProgram(of: buttonState) == program
        let isCompatible = isProgramCompatible(program)
        let infoType: ProgramInfoModalView.InfoType =
            isCompatible ? (shouldDisplayRemove ? .remove : .add) : .incompatible

        programInfoModal.configure(
            program: program,
            infoType: infoType,
            issue: isCompatible ? nil : ModalKeys.Program.compatibilityIssue.translate(),
            editButtonHandler: { [weak self] in
                self?.dismissModalViewController()
                let vc = AppContainer.shared.container.unwrappedResolve(ProgramsViewController.self)
                vc.selectedProgram = program
                vc.shouldDismissAfterSave = true
                self?.navigationController?.pushViewController(vc, animated: true)
        },
            actionButtonHandler: { [weak self] _ in
                if isCompatible {
                    self?.programSelected(shouldDisplayRemove ? nil: program, on: (self?.selectedButtonIndex)!)
                } else {
                    self?.dismissModalViewController()
                    self?.configurationView.set(state: (self?.selectedButtonState)!, on: (self?.selectedButtonIndex)!)
                }
        })

        presentModal(with: programInfoModal, onDismissed: onDismissed)
    }
}

// MARK: - Setups
extension PadConfigurationViewController {
    private func setupConfigurationView() {
        instantiateConfigurationView()
        configurationView.selectionCallback = { [weak self] index in
            self?.controllerButtonSelected(at: index)
        }
        setupConstraints()
    }

    private func instantiateConfigurationView() {
        guard let controllerType = controllerType else { return }
        switch controllerType {
        case .new, .gamer:
            configurationView = GamerConfigurationView.instatiate()
        case .driver:
            configurationView = DriverConfigurationView.instatiate()
        case .multiTasker:
            configurationView = MultiTaskerConfigurationView.instatiate()
        }
    }

    private func fetchSelectedController() {
        selectedController = realmService.getController(id: selectedControllerId)
    }

    private func setupViewModel() {
        viewModel.joystickPriority = selectedController?.joystickPriority ?? 0
        viewModel.name = selectedController?.name ?? ""
        viewModel.customDesctiprion = selectedController?.controllerDescription ?? ""
        viewModel.id = selectedController?.id ?? UUID().uuidString
        viewModel.configurationId = configurationId ?? ""
        viewModel.type = controllerType ?? .gamer
        viewModel.isNewlyCreated = selectedController == nil
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
