//
//  DashedView.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

@IBDesignable
final class DashedView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let dashedLinePadding: CGFloat = 0
    }

    // MARK: - Properties
    let dottedLineLayer = CAShapeLayer()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
}

// MARK: - Interface builder
extension DashedView {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

// MARK: - View lifecycle
extension DashedView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let path = CGMutablePath()
        if bounds.width > bounds.height {
            path.addLines(between: [CGPoint(x: 0 + Constants.dashedLinePadding, y: bounds.height / 2),
                                    CGPoint(x: bounds.width - Constants.dashedLinePadding, y: bounds.height / 2)])
        } else {
            path.addLines(between: [CGPoint(x: bounds.width / 2, y: 0 + Constants.dashedLinePadding),
                                    CGPoint(x: bounds.width / 2, y: bounds.height - Constants.dashedLinePadding)])
        }

        dottedLineLayer.path = path
    }
}

// MARK: - Setup
extension DashedView {
    private func setupView() {
        backgroundColor = .clear
        dottedLineLayer.strokeColor = Color.brownishGrey.cgColor
        dottedLineLayer.lineWidth = 1
        dottedLineLayer.lineDashPattern = [5, 5]
        dottedLineLayer.lineJoin = .round
        layer.addSublayer(dottedLineLayer)
    }
}
