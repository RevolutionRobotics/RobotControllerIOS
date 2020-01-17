//
//  ProgramsViewController+BlocklyBridgeDelegate.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 11. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import RevolutionRoboticsBlockly

extension ProgramsViewController: BlocklyBridgeDelegate {
    func motorSelector(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let mapping = realmService.getConfiguration(id: selectedProgramRobot?.configId)?.mapping
        guard let motors = mapping?.motors.filter({ $0?.type == MotorDataModel.Constants.motor }) else {
            callback?(inputHandler.defaultInput)
            return
        }
        let motorSelector = PeripheralSelector.instatiate()
        motorSelector.items = motors.compactMap({ $0?.variableName })
        motorSelector.selectedIndex = motorSelector.items?.firstIndex(where: { $0 == inputHandler.defaultInput })
        motorSelector.setup(
            titled: inputHandler.title,
            emptyText: ProgramsKeys.InputSelectionDialog.noMotor.translate())
        motorSelector.callback = { [weak self] motorIndex in
            callback?(motors[motorIndex]?.variableName)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: motorSelector, onDismissed: { callback?(nil) })
    }

    func sensorSelector(_ inputHandler: InputHandler, isBumper: Bool, callback: ((String?) -> Void)?) {
        let mapping = realmService.getConfiguration(id: selectedProgramRobot?.configId)?.mapping
        guard let sensors = mapping?.sensors.compactMap({ $0 }) else {
            callback?(inputHandler.defaultInput)
            return
        }
        let sensorSelectorSelector = PeripheralSelector.instatiate()
        let bumperType = SensorDataModel.Constants.bumper
        sensorSelectorSelector.items = sensors
            .filter({ ($0.type == bumperType && isBumper)
                || ($0.type != bumperType && !isBumper) })
            .map({ $0.variableName })
        sensorSelectorSelector.selectedIndex = sensorSelectorSelector.items?.firstIndex(where: {
            $0 == inputHandler.defaultInput
        })
        let strings = ProgramsKeys.InputSelectionDialog.self
        sensorSelectorSelector.setup(
            titled: inputHandler.title,
            emptyText: (isBumper ? strings.noBumper : strings.noSensor).translate())
        sensorSelectorSelector.callback = { [weak self] sensorIndex in
            callback?(sensors[sensorIndex].variableName)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: sensorSelectorSelector, onDismissed: { callback?(nil) })
    }

    func listSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let listSelector = PeripheralSelector.instatiate()
        listSelector.items = optionSelector.options.map({ $0.value })
        listSelector.setup(titled: optionSelector.title ?? "", emptyText: "")
        listSelector.selectedIndex = optionSelector.options
            .firstIndex(where: { $0.key == optionSelector.defaultKey }) ?? 0

        listSelector.callback = { [weak self] optionIndex in
            callback?(optionSelector.options[optionIndex].value)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: listSelector, onDismissed: { callback?(nil) })
    }

    func alert(message: String, callback: (() -> Void)?) {
        let alertView = AlertModalView.instatiate()
        alertView.setup(message: message) { [weak self] in
            callback?()
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: alertView, onDismissed: { callback?() })
    }

    func confirm(message: String, callback: ((Bool) -> Void)?) {
        let confirmView = ConfirmModalView.instatiate()

        confirmView.setup(title: message)
        confirmView.confirmSelected = { [weak self] confirmed in
            callback?(confirmed)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: confirmView, onDismissed: { callback?(false) })
    }

    func optionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let optionSelectorView = OptionSelectorModalView.instatiate()
        optionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: optionSelectorView, onDismissed: { callback?(nil) })
    }

    func driveDirectionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let driveDirectionSelectorView = DriveDirectionSelectorModalView.instatiate()
        driveDirectionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: driveDirectionSelectorView, onDismissed: { callback?(nil) })
    }

    func sliderHandler(_ sliderHandler: SliderHandler, callback: ((String?) -> Void)?) {
        let sliderInputView = SliderInputModalView.instatiate()
        sliderInputView.setup(sliderHandler: sliderHandler) { [weak self] value in
            callback?(value)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: sliderInputView, onDismissed: { callback?(nil) })
    }

    func singleLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorModalView.instatiate()
        let defaultValues = Set([inputHandler.defaultInput])

        ledSelectorView.setup(selectionType: .single, defaultValues: defaultValues) { [weak self] led in
            callback?(led)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func multiLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorModalView.instatiate()
        let defaultValues = Set(inputHandler.defaultInput.components(separatedBy: ","))

        ledSelectorView.setup(selectionType: .multi, defaultValues: defaultValues) { [weak self] leds in
            callback?(leds)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func colorSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let colorSelector = ColorSelectorModalView.instatiate()
        colorSelector.setup(optionSelector: optionSelector) { [weak self] color in
            callback?(color)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: colorSelector, onDismissed: { callback?(nil) })
    }

    func audioSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let soundPicker = SoundPickerModalView.instatiate()
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
        let textInput = TextInputModalView.instatiate()
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
        let blockContext = BlockContextMenuModalView.instatiate()
        blockContext.setup(with: contextHandler)
        blockContext.deleteCallback = { [weak self] in
           self?.dismiss(animated: true, completion: nil)
            callback?(DeleteBlockAction())
        }
        blockContext.duplicateCallback = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            callback?(DuplicateBlockAction())
        }
        blockContext.helpCallback = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            callback?(HelpAction())
        }
        presentModal(with: blockContext, onDismissed: {
            callback?(AddCommentAction(payload: blockContext.comment))
        })
    }

    func variableContext(_ optionSelector: OptionSelector, callback: ((VariableContextAction?) -> Void)?) {
        let variableContextView = VariableContextModalView.instatiate()
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
        guard let program = selectedProgram, programSaveReason == .edited else { return }
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
        switch programSaveReason {
        case .showCode:
            let codeView = CodePreviewModalView.instatiate()
            codeView.setup(with: pythonCode)
            codeView.doneCallback = { [weak self] in
                self?.dismissModalViewController()
            }
            presentModal(with: codeView)
        case .testCode:
            testPythonCode(with: pythonCode)
        case .edited:
            guard let program = selectedProgram else { return }
            realmService.updateObject {
                program.lastModified = Date()
                program.python = pythonCode.base64Encoded ?? ""
            }
        default:
            return
        }
        isPythonExported = true
        if isXMLExported && shouldDismissAfterSave {
            isXMLExported = false
            isPythonExported = false
            shouldDismissAfterSave = false
            navigationController?.popViewController(animated: true)
        }
    }

    func onXMLProgramSaved(xmlCode: String) {
        switch programSaveReason {
        case .navigateBack:
            onSavePromptDismissed(xmlCode: xmlCode, callback: navigateBack)
        case .newProgram:
            onSavePromptDismissed(xmlCode: xmlCode, callback: displayNew)
        case .openProgram:
            onSavePromptDismissed(xmlCode: xmlCode, callback: openProgramModal)
        case .edited:
            guard let program = selectedProgram else { return }
            realmService.updateObject {
                program.lastModified = Date()
                program.xml = xmlCode.base64Encoded ?? ""
            }
        default: return
        }
        isXMLExported = true
        if isPythonExported && shouldDismissAfterSave {
            isXMLExported = false
            isPythonExported = false
            shouldDismissAfterSave = false
            navigationController?.popViewController(animated: true)
        }
    }
}
