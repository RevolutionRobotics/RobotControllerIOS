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
    public func singleOptionSelector(_ optionSelector: SingleOptionSelector, callback: ((String?) -> Void)?) {
        let optionSelectorView = OptionSelectorView.instatiate()

        optionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: optionSelectorView, onDismissed: { callback?(nil) })
    }

    public func multiOptionSelector(_ optionSelector: MultiOptionSelector, callback: ((String?) -> Void)?) {
        callback?([
            optionSelector.options.randomElement()!.key,
            optionSelector.options.randomElement()!.key
            ].joined(separator: ",")
        )
    }

    public func colorSelector(_ optionSelector: SingleOptionSelector, callback: ((String?) -> Void)?) {
        callback?(optionSelector.options.randomElement()!.key)
    }

    public func audioSelector(_ optionSelector: SingleOptionSelector, callback: ((String?) -> Void)?) {
        callback?(optionSelector.options.randomElement()!.key)
    }

    public func numberInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        callback?("12")
    }

    public func textInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        callback?("Text")
    }

    public func blockContext(_ contextHandler: BlockContextHandler, callback: ((BlockContextAction?) -> Void)?) {
        callback?(AddCommentAction(payload: "New comment"))
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
