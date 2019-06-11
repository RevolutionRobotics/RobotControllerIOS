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
    // MARK: - Outlet
    @IBOutlet private weak var programNameButton: RRButton!
    @IBOutlet private weak var programCodeButton: RRButton!
    @IBOutlet private weak var saveProgramButton: RRButton!
    @IBOutlet private weak var openProgramButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlocklyViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
}

// MARK: - Setup
extension ProgramsViewController {
    private func setupBlocklyViewController() {
        let blocklyViewController = BlocklyViewController()
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
        callback?("Motor.DIRECTION_LEFT")
    }

    func sliderHandler(_ sliderHandler: SliderHandler, callback: ((String?) -> Void)?) {
        callback?("50")
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

        presentModal(with: colorSelector)
    }

    func audioSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        callback?(optionSelector.options.randomElement()!.key)
    }

    func numberInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        callback?("12")
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
