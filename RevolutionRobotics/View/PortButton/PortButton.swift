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
        case motor
        case sensor
    }

    var portType: PortType = .motor
    @IBInspectable var isMotor: Bool = true {
        didSet {
            portType = isMotor ? .motor : .sensor
        }
    }

    // MARK: - Port Number
    @IBInspectable var portNumber: Int = 0

    // MARK: - References
    var lines: [DashedView] = []
    var dotImageView: UIImageView! {
        didSet {
            dotImageView.tintColor = Color.brownishGrey
            dotImageView.image = UIImage(named: Constants.addIconDark)
        }
    }

    private let highlighterView = UIView()
    @IBInspectable var borderColor: UIColor? = .white {
        didSet {
            highlighterView.backgroundColor = borderColor
        }
    }

    // MARK: - Inits
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
        setImage(Image.Configuration.addIconLight, for: .normal)

        layoutIfNeeded()
        setBorder(strokeColor: Color.brownishGrey, lineWidth: Constants.borderWidth, dashPatter: Constants.dashPattern)
        setupHighligherView()
        setupToggle()
    }

    private func setupHighligherView() {
        addSubview(highlighterView)
        highlighterView.isHidden = true
        highlighterView.backgroundColor = borderColor
        highlighterView.anchorToSuperview(trailing: false)
        highlighterView.widthAnchor.constraint(equalToConstant: Constants.highlighterWidth).isActive = true
    }
}

// MARK: - Actions
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
        dotImageView.image = selected ? Image.Configuration.doneIcon : Image.Configuration.addIconDark
        dotImageView.tintColor = selected ? borderColor : .lightGray
    }

    private func setupHighlightetState() {
        setBorder(strokeColor: .white, lineWidth: Constants.borderWidth)
        setLineSelectedState(to: true, color: .white)
        dotImageView.image = Image.Configuration.addIconLight
    }

    private func setupSelectedState(with icon: UIImage?) {
        setBorder(strokeColor: borderColor, lineWidth: Constants.borderWidth)
        setLineSelectedState(to: true, color: borderColor)
        setupDotState(for: true)
        setImage(icon, for: .normal)
    }

    private func setupDeafultValues() {
        setBorder(strokeColor: Color.brownishGrey, lineWidth: Constants.borderWidth, dashPatter: Constants.dashPattern)
        setLineSelectedState(to: false)
        setupDotState(for: false)
    }

    private func setupToggle() {
        self.addTarget(self, action: #selector(buttonTouch), for: .touchUpInside)
    }

    @objc private func buttonTouch() {
        setupHighlightetState()
    }
}
