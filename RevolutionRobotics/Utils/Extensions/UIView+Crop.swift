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
        static let radius: CGFloat = 10.0
    }

    // MARK: - Properties
    private var bezierPathBorder: CAShapeLayer? {
        return (self.layer.sublayers?.filter({ (layer) -> Bool in
            return layer.name == Constants.bezierPathIdentifier && (layer as? CAShapeLayer) != nil
        }) as? [CAShapeLayer])?.first
    }

    // MARK: - public functions
    func crop(fillColor: UIColor = Color.darkGrey,
              strokeColor: UIColor = Color.lightGrey,
              lineWidth: CGFloat = 1.0,
              radius: CGFloat? = 10.0,
              corners: [Corner] = [.topRight, .bottomLeft]) {
        let border = self.bezierPathBorder ?? createBorder()
        self.layoutIfNeeded()
        createMask(with: createPath(with: radius ?? Constants.radius, corners: corners))
        border.frame = self.bounds
        setup(border: border,
              fillColor: fillColor,
              strokeColor: strokeColor,
              lineWidth: lineWidth,
              path: createPath(with: radius ?? Constants.radius, corners: corners))
    }

    func removeBezierPathBorder() {
        self.layer.mask = nil
        self.bezierPathBorder?.removeFromSuperlayer()
    }

    // MARK: - Private functions
    private func createBorder() -> CAShapeLayer {
        let border = CAShapeLayer()
        border.name = Constants.bezierPathIdentifier
        self.layer.insertSublayer(border, at: 0)
        return border
    }

    private func createMask(with path: UIBezierPath) {
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
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

    private func createPath(with radius: CGFloat, corners: [Corner]) -> UIBezierPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: corners.contains(.topLeft) ? radius : 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: radius))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height - radius))
        path.addLine(to: CGPoint(x: corners.contains(.bottomLeft) ? radius : 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: radius, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width - radius, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: corners.contains(.bottomRight) ?
            self.frame.size.height - radius : self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - radius))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: radius))
        path.addLine(to: CGPoint(x: corners.contains(.topRight) ?
            self.frame.size.width - radius : self.frame.size.width, y: 0.0))
        path.addLine(to: CGPoint(x: self.frame.size.width - radius, y: 0.0))
        path.close()

        return path
    }
}
