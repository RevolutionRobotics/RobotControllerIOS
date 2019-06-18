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
        callback?("2")
    }

    func multiLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        callback?("2,5,6")
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
        callback?(AddCommentAction(payload: "New comment").jsonSerialized)
    }

    func variableContext(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        callback?(DeleteVariableAction(payload: optionSelector.defaultKey).jsonSerialized)
    }

    func onVariablesExported(variables: String) {
        print("Variables = \(variables)")
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
        }
    }

    func onXMLProgramSaved(xmlCode: String) {
        print("XML = \(xmlCode)")
    }
}

// MARK: - Actions
extension ProgramsViewController {
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func programCodeButtonTapped(_ sender: UIButton) {
        showCode = true
        blocklyViewController.saveProgram()
    }

    @IBAction private func saveProgramButtonTapped(_ sender: UIButton) {
        print("Save program button tapped")
    }

    @IBAction private func openProgramButtonTapped(_ sender: UIButton) {
        let modal = ProgramsView.instatiate()
        modal.setup(with: realmService.getPrograms())
        modal.selectedProgramCallback = { [weak self] program in
            self?.dismissModalViewController()
            print("\(program)")
        }
        presentModal(with: modal)
    }
}
