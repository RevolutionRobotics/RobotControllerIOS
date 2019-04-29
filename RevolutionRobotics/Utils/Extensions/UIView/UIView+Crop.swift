//
//  UIView+Crop.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    enum Corner {
        case topLeft
        case bottomLeft
        case bottomRight
        case topRight
    }

    // MARK: - Constants
    private enum Constants {
        static let bezierPathIdentifier = "bezierPathBorderLayer"
    }

    // MARK: - Properties
    private var bezierPathBorder: CAShapeLayer? {
        return (layer.sublayers?.filter({ (layer) -> Bool in
            return layer.name == Constants.bezierPathIdentifier && (layer as? CAShapeLayer) != nil
        }) as? [CAShapeLayer])?.first
    }

    // MARK: - Public functions
    func setBorder(fillColor: UIColor = Color.blackTwo,
                   strokeColor: UIColor = Color.blackTwo,
                   lineWidth: CGFloat = 1.0,
                   radius: CGFloat = 10.0,
                   showTopArrow: Bool = false,
                   croppedCorners: [Corner] = [.topRight, .bottomLeft]) {
        let border = bezierPathBorder ?? createBorder()
        layoutIfNeeded()
        let path = createPath(with: radius, showTopArrow: showTopArrow, croppedCorners: croppedCorners)
        createMask(with: path)
        border.frame = bounds
        setup(border: border, fillColor: fillColor, strokeColor: strokeColor, lineWidth: lineWidth, path: path)
    }

    func removeBezierPathBorder() {
        layer.mask = nil
        bezierPathBorder?.removeFromSuperlayer()
    }

    // MARK: - Private functions
    private func createBorder() -> CAShapeLayer {
        let border = CAShapeLayer()
        border.name = Constants.bezierPathIdentifier
        layer.insertSublayer(border, at: 0)
        return border
    }

    private func createMask(with path: UIBezierPath) {
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    private func setup(border: CAShapeLayer,
                       fillColor: UIColor,
                       strokeColor: UIColor,
                       lineWidth: CGFloat,
                       path: UIBezierPath) {
        border.path = path.cgPath
        border.fillColor = fillColor.cgColor
        border.strokeColor = strokeColor.cgColor
        border.lineWidth = lineWidth
    }

    private func createPath(with radius: CGFloat, showTopArrow: Bool, croppedCorners: [Corner]) -> UIBezierPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: croppedCorners.contains(.topLeft) ? radius : 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: radius))
        path.addLine(to: CGPoint(x: 0.0, y: frame.size.height - radius))
        path.addLine(to: CGPoint(x: croppedCorners.contains(.bottomLeft) ? radius : 0.0, y: frame.size.height))
        path.addLine(to: CGPoint(x: radius, y: frame.size.height))
        path.addLine(to: CGPoint(x: frame.size.width - radius, y: frame.size.height))
        path.addLine(to: CGPoint(x: frame.size.width, y: croppedCorners.contains(.bottomRight) ?
            frame.size.height - radius : frame.size.height))
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - radius))
        path.addLine(to: CGPoint(x: frame.size.width, y: radius))
        path.addLine(to: CGPoint(x: croppedCorners.contains(.topRight) ?
            frame.size.width - radius : frame.size.width, y: 0.0))
        path.addLine(to: CGPoint(x: frame.size.width - radius, y: 0.0))
        if showTopArrow {
            path.addLine(to: CGPoint(x: (frame.size.width / 2) + radius, y: 0.0))
            path.addLine(to: CGPoint(x: frame.size.width / 2, y: -radius))
            path.addLine(to: CGPoint(x: (frame.size.width / 2) - radius, y: 0.0))
        }
        path.close()

        return path
    }
}
