//
//  LEDSelectorModalView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import PieCharts

final class LEDSelectorModalView: UIView {
    // MARK: - SelectionType
    enum SelectionType {
        case single
        case multi
    }

    // MARK: - Constants
    private enum Constants {
        static let labelFont = Font.barlow(size: 18.0, weight: .medium)
        static let correctionRotationAngle = CGFloat(Double.pi / 12)
        static let values: [String] = ["4", "5", "6", "7", "8", "9", "10", "11", "12", "1", "2", "3"]
    }

    // MARK: - Outlets
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet private weak var selectAllLabel: UILabel!
    @IBOutlet private weak var pieChart: PieChart!

    // MARK: - Properties
    private var ledSelected: CallbackType<String?>?
    private var selectionType = SelectionType.single
    private var selectedValues = Set<String>()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        setupDoneButton()
        setupSelectAllButton()
        setupPieChartTextLayer()
        setupPieChart()
    }
}

// MARK: - Setup
extension LEDSelectorModalView {
    func setup(selectionType: SelectionType, defaultValues: Set<String>, ledSelected: CallbackType<String?>?) {
        self.selectionType = selectionType

        changeSelectionTypeAppearance(to: selectionType)
        preselectValues(by: selectionType, defaultValues: defaultValues)

        self.ledSelected = ledSelected
    }

    private func setupDoneButton() {
        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        doneButton.setTitle(ModalKeys.Save.done.translate(), for: .normal)
    }

    private func setupSelectAllButton() {
        selectAllButton.setImage(Image.Programs.checkboxWhiteChecked, for: .selected)
        selectAllButton.setImage(Image.Programs.Buttonless.checkboxNotChecked, for: .normal)
        selectAllLabel.text = ModalKeys.Blockly.ledSelectorSelectAll.translate()
    }

    private func changeSelectionTypeAppearance(to selectionType: SelectionType) {
        selectAllLabel.isHidden = selectionType == .single
        selectAllButton.isHidden = selectionType == .single
        doneButton.isHidden = selectionType == .single
    }

    private func setupPieChart() {
        pieChart.delegate = self
        pieChart.models = Constants.values.map { PieSliceModel(value: 1, color: Color.black26, obj: $0) }
        pieChart.transform = CGAffineTransform(rotationAngle: Constants.correctionRotationAngle)
    }

    private func setupPieChartTextLayer() {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.label.textGenerator = { pieSlice in
            return pieSlice.data.model.obj as? String ?? ""
        }
        textLayerSettings.label.labelGenerator = { pieSlice in
            let label = UILabel()

            label.font = Constants.labelFont
            label.textColor = .white
            label.text = pieSlice.data.model.obj as? String
            label.transform = CGAffineTransform(rotationAngle: -Constants.correctionRotationAngle)

            return label
        }

        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        pieChart.layers = [textLayer]
    }
}

// MARK: - PieChartDelegate
extension LEDSelectorModalView: PieChartDelegate {
    func onSelected(slice: PieSlice, selected: Bool) {
        guard let value = slice.data.model.obj as? String else { return }
        let isSelected = !selectedValues.contains(value)

        select(value: value)
        renderValueSelection(in: slice, isSelected: isSelected)
        checkAllValueSelection()
    }
}

// MARK: - Selection
extension LEDSelectorModalView {
    private func preselectValues(by selectionType: SelectionType, defaultValues: Set<String>) {
        switch selectionType {
        case .single:
            let slice = pieChart.slices.first {
                guard let text = $0.data.model.obj as? String, let value = defaultValues.first else { return false }
                return text == value
            }
            guard let selectableSlice = slice else { return }

            pieChart.onSelected(slice: selectableSlice, selected: true)

        case .multi:
            let slices = pieChart.slices.filter {
                guard let text = $0.data.model.obj as? String else { return false }
                return defaultValues.contains(text)
            }

            slices.forEach { pieChart.onSelected(slice: $0, selected: true) }
        }
    }

    private func select(value: String) {
        switch selectionType {
        case .single:
            ledSelected?(value)
        case .multi:
            if selectedValues.contains(value) {
                selectedValues.remove(value)
            } else {
                selectedValues.update(with: value)
            }
        }
    }

    private func renderValueSelection(in slice: PieSlice, isSelected: Bool) {
        slice.view.color = isSelected ? .white : Color.black26
        let label = pieChart.subviews
            .compactMap { $0 as? UILabel }
            .first(where: { label in
                guard let text = label.text, let value = slice.data.model.obj as? String else { return false }
                return text == value
            })
        label?.textColor = isSelected ? Color.black : .white
    }

    private func toggleAllValueSelection() {
        selectAllButton.isSelected.toggle()
        if selectAllButton.isSelected {
            selectedValues.removeAll()
        } else {
            Constants.values.forEach { selectedValues.update(with: $0) }
        }

        pieChart.slices.forEach { pieChart.onSelected(slice: $0, selected: selectAllButton.isSelected) }
    }

    private func checkAllValueSelection() {
        selectAllButton.isSelected = selectedValues.count == Constants.values.count
    }
}

// MARK: - Actions
extension LEDSelectorModalView {
    @IBAction private func doneButtonTapped(_ sender: RRButton) {
        let sortedValues = selectedValues.compactMap(Int.init).sorted().map(String.init).joined(separator: ",")
        ledSelected?(sortedValues)
    }

    @IBAction private func selectAllButtonTapped(_ sender: RRButton) {
        toggleAllValueSelection()
    }
}
