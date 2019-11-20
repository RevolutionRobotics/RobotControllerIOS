//
//  PortButton.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

@IBDesignable
final class PortButton: UIButton {
    // MARK: - Constants
    private enum Constants {
        static let activeBorderWidth: CGFloat = 2
        static let imagePadding: CGFloat = 14
        static let dashPattern: [NSNumber] = [5, 5]
        static let borderWidth: CGFloat = 1.5
        static let fontSize: CGFloat = 16
        static let highlighterWidth: CGFloat = 6
        static let addIconDark = "addIconDark"
    }

    // MARK: - Port Type
    enum PortType {
        init?(string: String?) {
            guard let string = string else { return nil }
            switch string {
            case "motor":
                self = .motor
            case "drive":
                self = .drive
            case "bumper":
                self = .bumper
            case "distance":
                self = .distance
            default:
                return nil
            }
        }

        case motor
        case drive
        case bumper
        case distance
    }

    // MARK: - State
    enum PortState {
        case normal
        case highlighted
        case selected
    }

    // MARK: - Properties
    var portType: PortType = .motor
    var portState: PortState = .normal {
        didSet {
            setState(to: portState)
        }
    }
    var lines: [DashedView] = []
    var dotImageView: UIImageView! {
        didSet {
            dotImageView.tintColor = Color.brownishGrey
            dotImageView.image = UIImage(named: Constants.addIconDark)
        }
    }
    private let highlighterView = UIView()
    @IBInspectable var portNumber: Int = 0
    @IBInspectable var borderColor: UIColor? = .white {
        didSet {
            highlighterView.backgroundColor = borderColor
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
extension PortButton {
    private func setupView() {
        titleEdgeInsets = UIEdgeInsets(top: 0, left: Constants.imagePadding, bottom: 0, right: 0)
        adjustsImageWhenHighlighted = false
        backgroundColor = Color.brownGrey
        titleLabel?.font = Font.jura(size: Constants.fontSize, weight: .bold)
        setImage(Image.Configuration.Connections.addIconLight, for: .normal)

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
}

// MARK: - Private methods
extension PortButton {
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

    private func setupDotState(for selected: Bool) {
        dotImageView.image =
            selected ? Image.Configuration.Connections.doneIcon : Image.Configuration.Connections.addIconDark
        dotImageView.tintColor = selected ? borderColor : .lightGray
    }

    private func setState(to state: PortState) {
        switch state {
        case .normal:
            setupNormalState()
        case .highlighted:
            setupHighlightedState()
        case .selected:
            setupSelectedState()
        }
    }

    private func setupNormalState() {
        setBorder(fillColor: Color.blackTwo,
                  strokeColor: Color.brownishGrey,
                  lineWidth: Constants.borderWidth,
                  dashPatter: Constants.dashPattern)
        setTitleColor(.white, for: .normal)
        setLineSelectedState(to: false)
        setupDotState(for: false)
        setImage(Image.Configuration.Connections.addIconLight, for: .normal)
    }

    private func setupHighlightedState() {
        setBorder(fillColor: .white, strokeColor: .white, lineWidth: Constants.borderWidth)
        setTitleColor(Color.blackTwo, for: .normal)
        setLineSelectedState(to: true, color: .white)
        dotImageView.image = Image.Configuration.Connections.addIconLight
        setImage(Image.Configuration.Connections.addIconDark20, for: .normal)
    }

    private func setupSelectedState() {
        setBorder(fillColor: Color.blackTwo, strokeColor: borderColor, lineWidth: Constants.borderWidth)
        setTitleColor(.white, for: .normal)
        setLineSelectedState(to: true, color: borderColor)
        setupDotState(for: true)
        switch portType {
        case .motor:
            setImage(Image.Configuration.Connections.motorIcon, for: .normal)
        case .drive:
            setImage(Image.Configuration.Connections.driveIcon, for: .normal)
        case .bumper:
            setImage(Image.Configuration.Connections.bumperIcon, for: .normal)
        case .distance:
            setImage(Image.Configuration.Connections.distanceIcon, for: .normal)
        }
    }
}
