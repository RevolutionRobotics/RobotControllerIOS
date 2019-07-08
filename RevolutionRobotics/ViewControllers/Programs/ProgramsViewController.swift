//
//  ProgramsViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class ProgramsViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let defaultXMLCode = "<xml xmlns=\"http://www.w3.org/1999/xhtml\"></xml>"
    }

    // MARK: - Outlets
    @IBOutlet private weak var programNameButton: RRButton!
    @IBOutlet private weak var programCodeButton: RRButton!
    @IBOutlet private weak var saveProgramButton: RRButton!
    @IBOutlet private weak var openProgramButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var programCompatibilityValidator: ProgramCompatibilityValidator!
    var selectedProgram: ProgramDataModel?
    private var isBackButtonTapped = false
    private let blocklyViewController = BlocklyViewController()
    private var showCode: Bool = false
}

// MARK: - View lifecycle
extension ProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        programCompatibilityValidator = ProgramCompatibilityValidator(realmService: realmService)
        setupBlocklyViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedProgram != nil {
            prefillProgram()
        }

        setupButtons()
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

    private func setupButtons() {
        programNameButton.setBorder(fillColor: .clear)
        programCodeButton.setBorder(fillColor: .clear)
        saveProgramButton.setBorder(fillColor: .clear)
        openProgramButton.setBorder(fillColor: .clear)
    }

    private func prefillProgram() {
        guard let program = selectedProgram else { return }
        programNameButton.setTitle(program.name, for: .normal)
    }
}

// MARK: - Private functions
extension ProgramsViewController {
    private func saveProgram() {
        guard let program = selectedProgram else {
            return
        }

        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.variableNames = program.variableNames
                programDataModel.lastModified = Date()
                programDataModel.customDescription = program.customDescription
                programDataModel.xml = program.xml
                programDataModel.python = program.python
            }
        } else {
            realmService.savePrograms(programs: [program])
        }

        prefillProgram()
        setupButtons()
    }

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
        let descriptionModal = ProgramDescriptionView.instatiate()
        descriptionModal.setup(with: program)
        descriptionModal.loadCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.selectedProgram = program
            self?.blocklyViewController.loadProgram(xml: program.xml.base64Decoded ?? "")
            self?.prefillProgram()
            self?.setupButtons()
        }
        descriptionModal.deleteCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.realmService.deleteProgram(program)
        }
        presentModal(with: descriptionModal)
    }

    private func confirmLeave() {
        let confirmModal = ConfirmModalView.instatiate()
        confirmModal.setup(
            title: ProgramsKeys.NavigateBack.title.translate(),
            subtitle: ProgramsKeys.NavigateBack.subtitle.translate(),
            positiveButtonTitle: ProgramsKeys.NavigateBack.positive.translate()
        )
        confirmModal.confirmSelected = { [weak self] confirmed in
            self?.dismissModalViewController()
            if confirmed {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        presentModal(with: confirmModal)
    }

    private func openProgramModal() {
        let programsView = ProgramsView.instatiate()
        programsView.setup(with: realmService.getPrograms())
        programsView.selectedProgramCallback = { [weak self] program in
            self?.dismissModalViewController()
            self?.open(program: program)
        }
        presentModal(with: programsView)
    }
}

// MARK: - BlocklyBridgeDelegate
extension ProgramsViewController: BlocklyBridgeDelegate {
    func alert(message: String, callback: (() -> Void)?) {
        let alertView = AlertModalView.instatiate()

        alertView.setup(message: message) { [weak self] in
            callback?()
            self?.dismissModalViewController()
        }

        presentModal(with: alertView, onDismissed: { callback?() })
    }

    func confirm(message: String, callback: ((Bool) -> Void)?) {
        let confirmView = ConfirmModalView.instatiate()

        confirmView.setup(title: message)
        confirmView.confirmSelected = { [weak self] confirmed in
            callback?(confirmed)
            self?.dismissModalViewController()
        }

        presentModal(with: confirmView, onDismissed: { callback?(false) })
    }

    func optionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let optionSelectorView = OptionSelectorView.instatiate()

        optionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismissModalViewController()
        }

        presentModal(with: optionSelectorView, onDismissed: { callback?(nil) })
    }

    func driveDirectionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let driveDirectionSelectorView = DriveDirectionSelectorView.instatiate()

        driveDirectionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismissModalViewController()
        }

        presentModal(with: driveDirectionSelectorView, onDismissed: { callback?(nil) })
    }

    func sliderHandler(_ sliderHandler: SliderHandler, callback: ((String?) -> Void)?) {
        let sliderInputView = SliderInputView.instatiate()

        sliderInputView.setup(sliderHandler: sliderHandler) { [weak self] value in
            callback?(value)
            self?.dismissModalViewController()
        }

        presentModal(with: sliderInputView, onDismissed: { callback?(nil) })
    }

    func singleLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorView.instatiate()
        let defaultValues = Set([inputHandler.defaultInput])

        ledSelectorView.setup(selectionType: .single, defaultValues: defaultValues) { [weak self] led in
            callback?(led)
            self?.dismissModalViewController()
        }

        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func multiLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorView.instatiate()
        let defaultValues = Set(inputHandler.defaultInput.components(separatedBy: ","))

        ledSelectorView.setup(selectionType: .multi, defaultValues: defaultValues) { [weak self] leds in
            callback?(leds)
            self?.dismissModalViewController()
        }

        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func colorSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let colorSelector = ColorSelectorView.instatiate()

        colorSelector.setup(optionSelector: optionSelector) { [weak self] color in
            callback?(color)
            self?.dismissModalViewController()
        }

        presentModal(with: colorSelector, onDismissed: { callback?(nil) })
    }

    func audioSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let soundPicker = SoundPickerView.instatiate()

        soundPicker.setup(optionSelector: optionSelector) { [weak self] sound in
            callback?(sound)
            self?.dismissModalViewController()
        }

        presentModal(with: soundPicker, onDismissed: { callback?(nil) })
    }

    func numberInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let dialpadInputViewController = AppContainer.shared.container.unwrappedResolve(DialpadInputViewController.self)

        presentViewControllerModally(
            dialpadInputViewController,
            transitionStyle: .crossDissolve,
            presentationStyle: .overFullScreen
        )

        dialpadInputViewController.setup(inputHandler: inputHandler) { [weak self] text in
            callback?(text)
            self?.dismissModalViewController()
        }
    }

    func textInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let textInput = TextInputView.instatiate()
        textInput.setup(inputHandler: inputHandler)
        textInput.doneCallback = { [weak self] name in
            callback?(name)
            self?.dismiss(animated: true, completion: nil)
        }
        textInput.cancelCallback = { [weak self] in
            callback?(nil)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: textInput, onDismissed: { callback?(nil) })
    }

    func blockContext(_ contextHandler: BlockContextHandler, callback: ((BlockContextAction?) -> Void)?) {
        let blockContext = BlockContextView.instatiate()
        blockContext.setup(with: contextHandler)
        blockContext.deleteCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(DeleteBlockAction())
        }
        blockContext.duplicateCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(DuplicateBlockAction())
        }
        blockContext.helpCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(HelpAction())
        }

        presentModal(with: blockContext, onDismissed: {
            callback?(AddCommentAction(payload: blockContext.comment))
        })
    }

    func variableContext(_ optionSelector: OptionSelector, callback: ((VariableContextAction?) -> Void)?) {
        let variableContextView = VariableContextView.instatiate()

        variableContextView.setup(optionSelector: optionSelector) { [weak self] variableAction in
            callback?(variableAction)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: variableContextView, onDismissed: { callback?(nil) })
    }

    func onBlocklyLoaded() {
        guard let program = selectedProgram, let xml = program.xml.base64Decoded else { return }

        blocklyViewController.loadProgram(xml: xml)
    }

    func onVariablesExported(variables: String) {
        guard let program = selectedProgram, !showCode else { return }
        let variableList = variables.components(separatedBy: ",").filter { !$0.isEmpty }
        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.lastModified = Date()
                programDataModel.variableNames.removeAll()
                programDataModel.variableNames.append(objectsIn: variableList)
            }
            programCompatibilityValidator.validate(program: programDataModel)

        } else {
            program.variableNames.removeAll()
            program.variableNames.append(objectsIn: variableList)
            saveProgram()
            programCompatibilityValidator.validate(program: program)
        }

    }

    func onPythonProgramSaved(pythonCode: String) {
        if showCode {
            showCode = false
            let modal = ShowCodeView.instatiate()
            modal.setup(with: pythonCode)
            modal.doneCallback = { [weak self] in
                self?.dismissModalViewController()
            }
            presentModal(with: modal)
        } else {
            guard let program = selectedProgram else { return }

            realmService.updateObject(closure: {
                program.lastModified = Date()
                program.python = pythonCode.base64Encoded ?? ""
            })
        }
    }

    func onXMLProgramSaved(xmlCode: String) {
        if isBackButtonTapped {
            isBackButtonTapped = false
            if let selectedProgram = selectedProgram {
                if selectedProgram.xml.base64Decoded != xmlCode {
                    confirmLeave()
                } else {
                    navigationController?.popViewController(animated: true)
                }
            } else {
                if xmlCode == Constants.defaultXMLCode {
                    navigationController?.popViewController(animated: true)
                } else {
                    confirmLeave()
                }
            }
        } else {
            guard let program = selectedProgram, !showCode else { return }

            realmService.updateObject(closure: {
                program.lastModified = Date()
                program.xml = xmlCode.base64Encoded ?? ""
            })
        }
    }
}

// MARK: - Actions
extension ProgramsViewController {
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        blocklyViewController.saveProgram()
        isBackButtonTapped = true
    }

    @IBAction private func programCodeButtonTapped(_ sender: UIButton) {
        showCode = true
        blocklyViewController.saveProgram()
    }

    @IBAction private func saveProgramButtonTapped(_ sender: UIButton) {
        let saveModal = SaveProgramView.instatiate()
        if let program = selectedProgram {
            saveModal.setup(with: program)
        }
        saveModal.doneCallback = { [weak self] saveData in
            self?.dismissModalViewController()
            guard !(self?.realmService.getPrograms()
                .contains(where: { $0.name == saveData.name && !$0.remoteId.isEmpty }) ?? true) else {
                    let alert = UIAlertController(title: nil,
                                                  message: ProgramsKeys.SaveProgram.nameInUse.translate(),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: CommonKeys.errorOk.translate(),
                                                  style: .default,
                                                  handler: nil))
                    self?.present(alert, animated: true)
                    return
            }
            if self?.selectedProgram == nil {
                self?.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self?.selectedProgram?.name = saveData.name
            } else if self?.selectedProgram!.name != saveData.name {
                self?.selectedProgram = nil
                self?.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self?.selectedProgram?.name = saveData.name
            }
            if let description = saveData.description {
                self?.save(description: description)
            }
            self?.blocklyViewController.saveProgram()
        }
        presentModal(with: saveModal)
    }

    @IBAction private func openProgramButtonTapped(_ sender: UIButton) {
        guard selectedProgram != nil else {
            openProgramModal()
            return
        }

        let confirmModal = ConfirmModalView.instatiate()
        confirmModal.setup(
            title: ProgramsKeys.ConfirmOpen.title.translate(),
            subtitle: ProgramsKeys.ConfirmOpen.subtitle.translate(),
            positiveButtonTitle: ProgramsKeys.ConfirmOpen.positive.translate()
        )
        confirmModal.confirmSelected = { [weak self] confirmed in
            self?.dismissModalViewController()
            if confirmed {
                self?.openProgramModal()
            }
        }
        presentModal(with: confirmModal)

    }
}
