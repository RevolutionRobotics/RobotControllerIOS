//
//  SegmentedControl.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum ConfigurationSegment: Int {
    case connections
    case controllers
}

final class SegmentedControl: UIView {
    private let stackView = UIStackView()
    private var buttons: [SegmentedControlButton] = []
    var selectedSegment: ConfigurationSegment = .connections

    // MARK: - Selected callback
    var selectionCallback: CallbackType<ConfigurationSegment>?

    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}

// MARK: - Setups
extension SegmentedControl {
    func setup(with titles: [String]) {
        titles.enumerated().forEach { (offset: Int, element: String) in
            var croppedCorners: [UIView.Corner] = []

            if offset == 0 {
                croppedCorners = [.bottomLeft, .topLeft]
            } else if offset == titles.count - 1 {
                croppedCorners = [.bottomRight, .topRight]
            }

            let button = SegmentedControlButton()
            button.index = offset
            button.selectedSegment = ConfigurationSegment(rawValue: offset) ?? ConfigurationSegment.connections
            button.croppedCorners = croppedCorners
            button.setTitle(element, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)

            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    private func setupView() {
        setupStackView()
    }

    private func setupStackView() {
        addSubview(stackView)
        stackView.anchorToSuperview()
    }
}

// MARK: - Actions
extension SegmentedControl {
    func setSelectedIndex(_ index: Int) {
        guard index >= 0, index <= buttons.count - 1 else { return }
        buttons[index].isSelected = true
        guard let segment = ConfigurationSegment(rawValue: index) else { return }
        selectionCallback?(segment)
        selectedSegment = segment
    }

    @objc private func buttonTapped(sender: SegmentedControlButton) {
        resetButtons()
        sender.isSelected = true
        selectionCallback?(sender.selectedSegment)
        selectedSegment = sender.selectedSegment
    }

    private func resetButtons() {
        buttons.forEach {
            $0.isSelected = false
        }
    }
}

// MARK: - Segmenten Control Item
private class SegmentedControlButton: UIButton {
    public var index: Int!
    var croppedCorners: [UIView.Corner] = []
    var selectedSegment: ConfigurationSegment = .connections

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setBorder(strokeColor: isSelected ? .white : .clear, croppedCorners: croppedCorners)
    }

    override var isSelected: Bool {
        didSet {
            setBorder(strokeColor: isSelected ? .white : .clear, croppedCorners: croppedCorners)
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 36).isActive = true
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleLabel?.font = Font.barlow(size: 14, weight: .medium)
    }
}
