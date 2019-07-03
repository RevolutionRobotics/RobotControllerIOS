//
//  VariableContextView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 14..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class VariableContextView: UIView {
    // MARK: - Constant
    private enum Constant {
        static let rowHeight: CGFloat = 52.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private var variableContextActionSelected: CallbackType<VariableContextAction?>?
    private var variables: [Option] = []
    private var defaultVariableKey: String?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupTableView()
        setupDoneButton()
    }
 }

// MARK: - Setup
extension VariableContextView {
    func setup(optionSelector: OptionSelector, variableContextActionSelected: CallbackType<VariableContextAction?>?) {
        self.variableContextActionSelected = variableContextActionSelected
        defaultVariableKey = optionSelector.defaultKey
        variables = optionSelector.options.dropLast()

        titleLabel.text = optionSelector.title?.uppercased()
    }

    private func setupDoneButton() {
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.setTitle(ModalKeys.Blockly.deleteVariable.translate(), for: .normal)
    }

    private func setupTableView() {
        tableView.register(VariableContextCell.self)
        tableView.rowHeight = Constant.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - UITableViewDelegate
extension VariableContextView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        variableContextActionSelected?(SetVariableAction(payload: variables[indexPath.row].key))
    }
}

// MARK: - UITableViewDataSource
extension VariableContextView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VariableContextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

        let variable = variables[indexPath.row]
        cell.setup(variableName: variable.value)

        if let defaultVariableKey = defaultVariableKey {
            cell.isSelected = variable.key == defaultVariableKey
        }

        return cell
    }
}

// MARK: - Action
extension VariableContextView {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let defaultVariableKey = defaultVariableKey else { return }
        variableContextActionSelected?(DeleteVariableAction(payload: defaultVariableKey))
    }
}
