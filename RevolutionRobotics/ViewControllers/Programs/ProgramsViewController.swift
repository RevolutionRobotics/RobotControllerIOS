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
    // MARK: - Outlets
    @IBOutlet private weak var programNameButton: RRButton!
    @IBOutlet private weak var programCodeButton: RRButton!
    @IBOutlet private weak var saveProgramButton: RRButton!
    @IBOutlet private weak var openProgramButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var selectedProgram: ProgramDataModel?
    private let blocklyViewController = BlocklyViewController()
    private var showCode: Bool = false
}

// MARK: - View lifecycle
extension ProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
        programNameButton.setBorder()
        programCodeButton.setBorder()
        saveProgramButton.setBorder()
        openProgramButton.setBorder()
    }

    private func prefillProgram() {
        programNameButton.setTitle(selectedProgram?.name, for: .normal)
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
        guard let program = selectedProgram else {
            return
        }
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
            let xmlString = String(data: Data(base64Encoded: program.xml)!, encoding: .utf8)
            self?.blocklyViewController.loadProgram(xml: xmlString ?? "")
            self?.prefillProgram()
            self?.setupButtons()
        }
        descriptionModal.deleteCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.realmService.deleteProgram(program)
        }
        presentModal(with: descriptionModal)
    }
}

// MARK: - BlocklyBridgeDelegate
extension ProgramsViewController: BlocklyBridgeDelegate {
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

    func blockContext(_ contextHandler: BlockContextHandler, callback: ((String?) -> Void)?) {
        let modal = BlockContextView.instatiate()
        modal.setup(with: contextHandler)
        modal.deleteCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(DeleteBlockAction(payload: "").jsonSerialized)
        }
        modal.duplicateCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(DuplicateBlockAction(payload: "").jsonSerialized)
        }
        modal.helpCallback = { [weak self] in
            self?.dismissModalViewController()
            callback?(HelpAction(payload: "").jsonSerialized)
        }
        presentModal(with: modal, onDismissed: {
            callback?(AddCommentAction(payload: modal.getComment()).jsonSerialized)
        })
    }

    func variableContext(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let variableContextView = VariableContextView.instatiate()

        variableContextView.setup(optionSelector: optionSelector) { [weak self] variableAction in
            callback?(variableAction)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: variableContextView, onDismissed: { callback?(nil) })
    }

    func onVariablesExported(variables: String) {
        guard let program = selectedProgram, !showCode else {
            return
        }
        let variableList = variables.components(separatedBy: ",")
        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.variableNames.append(objectsIn: variableList.filter({ !$0.isEmpty }))
            }
        } else {
            program.variableNames.append(objectsIn: variableList.filter({ !$0.isEmpty }))
            saveProgram()
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
                program.python = pythonCode.data(using: .utf8)?.base64EncodedString() ?? ""
            })
        }
    }

    func onXMLProgramSaved(xmlCode: String) {
        guard let program = selectedProgram, !showCode else { return }

        realmService.updateObject(closure: {
            program.xml = xmlCode.data(using: .utf8)?.base64EncodedString() ?? ""
        })
    }
}

// MARK: - Actions
extension ProgramsViewController {
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: ProgramsKeys.navigateBackTitle.translate(),
                                      message: ProgramsKeys.navigateBackDescription.translate(),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: CommonKeys.no.translate(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: ProgramsKeys.navigateBackPositive.translate(),
                                      style: .destructive,
                                      handler: { [weak self] _ in
                                        self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
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
        let modal = ProgramsView.instatiate()
        modal.setup(with: realmService.getPrograms())
        modal.selectedProgramCallback = { [weak self] program in
            self?.dismissModalViewController()
            self?.open(program: program)
        }
        presentModal(with: modal)
    }
}
