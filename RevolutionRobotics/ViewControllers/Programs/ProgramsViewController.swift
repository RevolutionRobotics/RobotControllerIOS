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
    var selectedProgram: ProgramDataModel?
    private let blocklyViewController = BlocklyViewController()
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
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: optionSelectorView, onDismissed: { callback?(nil) })
    }

    func driveDirectionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let driveDirectionSelectorView = DriveDirectionSelectorView.instatiate()

        driveDirectionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: driveDirectionSelectorView, onDismissed: { callback?(nil) })
    }

    func sliderHandler(_ sliderHandler: SliderHandler, callback: ((String?) -> Void)?) {
        let sliderInputView = SliderInputView.instatiate()

        sliderInputView.setup(sliderHandler: sliderHandler) { [weak self] value in
            callback?(value)
            self?.dismiss(animated: true, completion: nil)
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
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: colorSelector, onDismissed: { callback?(nil) })
    }

    func audioSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let soundPicker = SoundPickerView.instatiate()

        soundPicker.setup(optionSelector: optionSelector) { [weak self] sound in
            callback?(sound)
            self?.dismiss(animated: true, completion: nil)
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
            self?.dismiss(animated: true, completion: nil)
        }
    }

    func textInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        callback?("Text")
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
        print("PythonCode = \(pythonCode)")
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
        print("Program Code button tapped")
    }

    @IBAction private func saveProgramButtonTapped(_ sender: UIButton) {
        print("Save program button tapped")
    }

    @IBAction private func openProgramButtonTapped(_ sender: UIButton) {
        print("Open program button tapped")
    }
}
