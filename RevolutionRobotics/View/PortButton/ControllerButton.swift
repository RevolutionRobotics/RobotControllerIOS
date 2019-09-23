//
//  ControllerButton.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 20..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
final class ControllerButton: UIButton {
    // MARK: - Constants
    private enum Constants {
        static let dashPattern: [NSNumber] = [5, 5]
        static let borderWidth: CGFloat = 2
        static let font = Font.jura(size: 10.0, weight: .bold)
        static let highlighterWidth: CGFloat = 4
    }

    // MARK: - State
    enum ControllerButtonState: Equatable {
        case normal
        case highlighted
        case selected(ProgramDataModel)
    }

    // MARK: - Properties
    @IBInspectable var buttonNumber: Int = 0
    var buttonState: ControllerButtonState = .normal {
        didSet {
            setState(to: buttonState)
        }
    }
    var lines: [DashedView] = []
    private let highlighterView = UIView()
    @IBInspectable var borderColor: UIColor? = .white {
        didSet {
            highlighterView.backgroundColor = borderColor
        }
    }
    var dotImageView: UIImageView! {
        didSet {
            setupDotState(for: buttonState != .normal)
        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

// MARK: - Setups
extension ControllerButton {
    private func setupView() {
        adjustsImageWhenHighlighted = false
        backgroundColor = Color.brownGrey
        titleLabel?.font = Constants.font

        layoutIfNeeded()
        setBorder(strokeColor: Color.brownishGrey, lineWidth: Constants.borderWidth, dashPatter: Constants.dashPattern)
        setupHighligherView()
    }

    private func setupHighligherView() {
        addSubview(highlighterView)
        highlighterView.isHidden = true
        highlighterView.backgroundColor = borderColor
        highlighterView.anchorToSuperview(trailing: false)
        highlighterView.widthAnchor.constraint(equalToConstant: Constants.highlighterWidth).isActive = true
    }

    private func setupDotState(for selected: Bool) {
        dotImageView.image =
            selected ? Image.Controller.assignedButtonIcon : Image.Controller.unassignedButtonIcon
        dotImageView.tintColor = selected ? borderColor : .lightGray
    }
}

// MARK: - Public functions
extension ControllerButton {
    func setupStaticState() {
        isUserInteractionEnabled = false
        setBorder(strokeColor: Color.brownGrey, lineWidth: Constants.borderWidth)
        setLineSelectedState(to: true, color: Color.brownGrey)
    }
}

// MARK: - Private methods
extension ControllerButton {
    private func setLineSelectedState(to selected: Bool, color: UIColor? = Color.brownishGrey) {
        highlighterView.backgroundColor = color
        highlighterView.isHidden = !selected
        lines.forEach {
            if selected {
                $0.dottedLineLayer.strokeColor = color?.cgColor
                $0.dottedLineLayer.lineDashPattern = []
            } else {
                $0.dottedLineLayer.strokeColor = Color.brownishGrey.cgColor
                $0.dottedLineLayer.lineDashPattern = Constants.dashPattern
            }
        }
    }

    private func setState(to state: ControllerButtonState) {
        switch state {
        case .normal:
            setupNormalState()
        case .highlighted:
            setupHighlightedState()
        case .selected(let program):
            setupSelectedState(programName: program.name)
        }
    }

    private func setupNormalState() {
        setBorder(fillColor: Color.blackTwo,
                  strokeColor: Color.brownishGrey,
                  lineWidth: Constants.borderWidth,
                  dashPatter: Constants.dashPattern)
        setTitle(ControllerKeys.configureEmpty.translate(), for: .normal)
        setTitleColor(.white, for: .normal)
        setLineSelectedState(to: false)
        backgroundColor = Color.blackTwo
        titleLabel?.textColor = .white
        setupDotState(for: false)
    }

    private func setupHighlightedState() {
        setBorder(fillColor: .white, strokeColor: .white, lineWidth: Constants.borderWidth)
        setTitleColor(Color.blackTwo, for: .normal)
        setLineSelectedState(to: true, color: .white)
        dotImageView.image = Image.Controller.highlightedButtonIcon
    }

    private func setupSelectedState(programName: String) {
        setTitle(programName, for: .normal)
        setBorder(fillColor: Color.blackTwo, strokeColor: Color.brightRed, lineWidth: Constants.borderWidth)
        setTitleColor(.white, for: .normal)
        setLineSelectedState(to: true, color: Color.brightRed)
        setupDotState(for: true)
    }
}
