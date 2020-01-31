//
//  ProgramsViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly
import os

final class ProgramsViewController: BaseViewController {
    internal enum ProgramSaveReason {
        case newProgram, edited, navigateBack, openProgram, showCode, testCode
    }

    // MARK: - Constants
    private enum Constants {
        static let testCodeName = "test_code"
        static let defaultXMLCode = "<xml xmlns=\"http://www.w3.org/1999/xhtml\"></xml>"
        static let blocklyElementIdRegex = "id=\"[^\"]*\""
    }

    // MARK: - Outlets
    @IBOutlet private weak var programNameButton: RRButton!
    @IBOutlet private weak var newProgramButton: RRButton!
    @IBOutlet private weak var saveProgramButton: RRButton!
    @IBOutlet private weak var openProgramButton: RRButton!
    @IBOutlet private weak var testButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var programCompatibilityValidator: ProgramCompatibilityValidator!
    var selectedProgram: ProgramDataModel? {
        didSet {
            guard let selectedProgram = selectedProgram else { return }
            UserDefaults.standard.set(selectedProgram.id, forKey: UserDefaults.Keys.mostRecentProgram)
        }
    }

    var openedFromMenu = false
    var shouldDismissAfterSave = false
    var isPythonExported = false
    var isXMLExported = false

    internal let blocklyViewController = BlocklyViewController()
    internal var selectedProgramRobot: UserRobot?
    internal var programSaveReason: ProgramSaveReason? = .edited {
        didSet {
            guard programSaveReason != nil else { return }
            blocklyViewController.saveProgram()
        }
    }
}

// MARK: - View lifecycle
extension ProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        programCompatibilityValidator = ProgramCompatibilityValidator(realmService: realmService)
        setupBlocklyViewController()
        loadMostRecentProgram()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedProgram != nil {
            prefillProgram()
        }
        setupButtons()
    }
}

// MARK: - Bluetooth connection
extension ProgramsViewController {
    override func connected() {
        bluetoothService.stopDiscovery()
        dismiss(animated: true, completion: { [weak self] in
            self?.testButtonTapped(UIButton())
        })
    }
}

// MARK: - Setup
extension ProgramsViewController {
    private func setupBlocklyViewController() {
        blocklyViewController.setup(blocklyBridgeDelegate: self)
        containerView.addSubview(blocklyViewController.view)
        blocklyViewController.view.anchorToSuperview()
        addChild(blocklyViewController)
        blocklyViewController.didMove(toParent: self)
    }

    private func loadMostRecentProgram() {
        let mostRecentProgramId = UserDefaults.standard
            .string(forKey: UserDefaults.Keys.mostRecentProgram)
        guard let program = realmService.getProgram(id: mostRecentProgramId) else {
            selectRobot()
            return
        }

        selectedProgramRobot = realmService.getRobot(program.robotId)
        selectedProgram = program
        blocklyViewController.loadProgram(xml: program.xml.base64Decoded ?? "")
        prefillProgram()
        setupButtons()
    }

    private func setupButtons() {
        programNameButton.setBorder(fillColor: .clear)
        saveProgramButton.setBorder(fillColor: .clear)
        testButton.setBorder(fillColor: .clear)
        testButton.setTitle(ProgramsKeys.Main.test.translate(), for: .normal)

        guard !openedFromMenu else {
            newProgramButton.setBorder(fillColor: .clear)
            openProgramButton.setBorder(fillColor: .clear)
            return
        }

        newProgramButton.isHidden = true
        openProgramButton.isHidden = true
        NSLayoutConstraint.activate([
            saveProgramButton.trailingAnchor.constraint(equalTo: newProgramButton.trailingAnchor)
        ])
    }

    private func prefillProgram() {
        guard let program = selectedProgram else { return }
        programNameButton.setTitle(program.name, for: .normal)
        selectedProgramRobot = realmService.getRobot(program.robotId)
    }
}

// MARK: - Private methods
extension ProgramsViewController {
    private func save(description: String) {
        guard let program = selectedProgram else { return }
        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.customDescription = description
            }
        } else {
            program.customDescription = description
            saveProgram()
        }
    }

    private func open(program: ProgramDataModel) {
        let descriptionModal = ProgramDescriptionModalView.instatiate()
        descriptionModal.setup(with: program)
        descriptionModal.loadCallback = { [weak self] in
            guard let `self` = self else { return }
            self.dismissModalViewController()
            self.selectedProgram = program
            self.blocklyViewController.loadProgram(xml: program.xml.base64Decoded ?? "")
            self.prefillProgram()
            self.setupButtons()
        }
        descriptionModal.deleteCallback = { [weak self] in
            guard let `self` = self else { return }
            self.dismissModalViewController()
            self.realmService.deleteProgram(program)
        }
        presentModal(with: descriptionModal)
    }

    private func confirmLeave() {
        let confirmModal = ConfirmModalView.instatiate()
        switch programSaveReason {
        case .navigateBack:
            confirmModal.setup(title: ProgramsKeys.NavigateBack.title.translate(),
                               subtitle: nil,
                               negativeButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmNegative.translate(),
                               positiveButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmPositive.translate())

            confirmModal.confirmSelected = { [weak self] confirmed in
                self?.dismissModalViewController()
                if confirmed {
                    self?.initiateSave(shouldNavigateBack: true, shouldOpenPrograms: false)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        case .openProgram:
            confirmModal.setup(title: ProgramsKeys.ConfirmOpen.title.translate(),
                               subtitle: nil,
                               negativeButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmNegative.translate(),
                               positiveButtonTitle: ProgramsKeys.NavigateBack.programOpenConfirmPositive.translate())
            confirmModal.confirmSelected = { [weak self] confirmed in
                self?.dismissModalViewController()
                confirmed
                    ? self?.initiateSave(shouldNavigateBack: false, shouldOpenPrograms: true)
                    : self?.openProgramModal()
            }
        case .newProgram:
            confirmModal.setup(title: ProgramsKeys.ConfirmNew.title.translate(),
                               subtitle: ProgramsKeys.ConfirmNew.subtitle.translate(),
                               negativeButtonTitle: ProgramsKeys.ConfirmNew.negative.translate(),
                               positiveButtonTitle: ProgramsKeys.ConfirmNew.positive.translate())
            confirmModal.confirmSelected = { [weak self] confirmed in
                self?.dismissModalViewController()
                confirmed
                    ? self?.initiateSave(shouldNavigateBack: false, shouldOpenPrograms: false)
                    : self?.displayNew()
            }
        default: return
        }
        presentModal(with: confirmModal)
    }

    private func canBeOverwritten(name: String?) -> Bool {
        guard let name = name else { return true }
        return !realmService.getPrograms().contains(where: { $0.name == name && !$0.remoteId.isEmpty })
    }

    private func selectRobot() {
        let robotList = realmService.getRobots()
        guard !robotList.isEmpty else {
            let alert = UIAlertController.errorAlert(type: .robotListEmpty)
            alert.addAction(UIAlertAction(
                title: CommonKeys.errorOk.translate(),
                style: .default,
                handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
            return
        }

        let robotsView = RobotListModalView.instatiate()
        robotsView.setup(with: robotList)
        robotsView.selectedRobotCallback = { [weak self] robot in
            guard let `self` = self else { return }
            self.dismissModalViewController()
            self.selectedProgramRobot = robot
        }
        presentUndismissableModal(with: robotsView, animated: true)
    }

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

    internal func saveProgram() {
        guard
            let program = selectedProgram,
            let robotId = selectedProgramRobot?.id
        else { return }

        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.variableNames = program.variableNames
                programDataModel.lastModified = Date()
                programDataModel.customDescription = program.customDescription
                programDataModel.xml = program.xml
                programDataModel.python = program.python
                programDataModel.robotId = robotId
            }
        } else {
            program.robotId = robotId
            realmService.savePrograms(programs: [program])
        }
        prefillProgram()
        setupButtons()
    }

    internal func openProgramModal() {
        let programsView = ProgramListModalView.instatiate()
        programsView.setup(with: realmService.getPrograms(), robots: realmService.getRobots())
        programsView.selectedProgramCallback = { [weak self] program in
            guard let `self` = self else { return }
            self.programSaveReason = nil
            self.dismissModalViewController()
            self.open(program: program)
            self.logEvent(named: "open_program")
        }
        presentModal(with: programsView)
    }

    internal func displayNew() {
        selectedProgram = nil
        programSaveReason = nil
        selectRobot()
        blocklyViewController.clearWorkspace()
        programNameButton.setTitle(ProgramsKeys.Main.untitled.translate(), for: .normal)
        programNameButton.setBorder(fillColor: .clear)
        logEvent(named: "create_new_program")
    }

    internal func onSavePromptDismissed(xmlCode: String, callback: Callback) {
        let isDefaultProgram = xmlCode == Constants.defaultXMLCode
        guard let selectedProgram = selectedProgram else {
            (isDefaultProgram ? callback : confirmLeave)()
            return
        }
        let replaced =
            selectedProgram.xml.base64Decoded?.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)
        let isXmlModified = replaced != xmlCode.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)
        (isXmlModified ? confirmLeave : callback)()
    }
}

// MARK: - Code testing
extension ProgramsViewController {
    private func testModalDismissed() {
        bluetoothService.stopKeepalive()
        dismissModalViewController()
    }

    private func sendConfiguration(thenRun code: String) {
        guard
            let encodedCode = code.base64Encoded,
            let configId = selectedProgramRobot?.configId,
            let config = realmService.getConfiguration(id: configId)
        else { return }

        let testModal = CodeTestModalView.instatiate()
        testModal.stopPressedCallback = { [weak self] in
            self?.testModalDismissed()
        }

        presentModal(with: testModal, onDismissed: { [weak self] in
            self?.testModalDismissed()
        })

        let binding = ProgramBindingDataModel(programId: Constants.testCodeName, priority: 0)
        let backgroundProgram = ProgramDataModel(id: Constants.testCodeName)
        backgroundProgram.python = encodedCode

        let controller = ControllerDataModel(
            id: UUID().uuidString,
            configurationId: configId,
            type: ControllerType.gamer.rawValue,
            mapping: ControllerButtonMappingDataModel())

        controller.backgroundProgramBindings.append(binding)
        controller.joystickPriority = 100

        let data = ConfigurationJSONData(
            configuration: config,
            controller: controller,
            programs: [backgroundProgram])
        do {
            let encodedData = try JSONEncoder().encode(data)
            bluetoothService.sendConfigurationData(encodedData, onCompleted: { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    testModal.updateLabel(isRunning: true)
                    self.bluetoothService.startKeepalive()
                case .failure:
                    os_log("Error while sending configuration to the robot!")
                    self.bluetoothService.stopKeepalive()
                }
            })
        } catch {
            os_log("Error while encoding the configuration!")
        }
    }

    internal func testPythonCode(with code: String) {
        guard bluetoothService.connectedDevice != nil else {
            presentConnectModal()
            return
        }
        sendConfiguration(thenRun: code)
    }
}

// MARK: - Actions
extension ProgramsViewController {
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        programSaveReason = .navigateBack
    }

    @IBAction private func newProgramButtonTapped(_ sender: UIButton) {
        programSaveReason = .newProgram
    }

    @IBAction private func openProgramButtonTapped(_ sender: UIButton) {
        programSaveReason = .openProgram
    }

    @IBAction private func testButtonTapped(_ sender: UIButton) {
        programSaveReason = .testCode
    }

    @IBAction private func saveProgramButtonTapped(_ sender: UIButton) {
        initiateSave(shouldNavigateBack: false, shouldOpenPrograms: false)
    }

    private func initiateSave(shouldNavigateBack: Bool, shouldOpenPrograms: Bool) {
        let saveModal = SaveProgramModalView.instatiate()
        if let program = selectedProgram {
            saveModal.setup(with: program)
        }
        saveModal.doneCallback = { [weak self] saveData in
            guard let `self` = self else { return }
            self.dismissModalViewController()
            guard self.canBeOverwritten(name: saveData.name) else {
                self.present(UIAlertController.errorAlert(type: .programAlreadyExists), animated: true)
                return
            }
            if self.selectedProgram == nil {
                self.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self.selectedProgram?.name = saveData.name
            } else if self.selectedProgram!.name != saveData.name {
                self.selectedProgram = nil
                self.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self.selectedProgram?.name = saveData.name
            }
            if let description = saveData.description {
                self.save(description: description)
            }
            self.programSaveReason = .edited

            if shouldNavigateBack {
                self.navigationController?.popViewController(animated: true)
            } else if shouldOpenPrograms {
                self.openProgramModal()
            }
        }
        presentModal(with: saveModal)
    }
}
