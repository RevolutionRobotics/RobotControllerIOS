//
//  RRSlider.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRSlider: UISlider {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 14.0
        static let verticalOffset: CGFloat = 3.0
        static let zPosition: CGFloat = 1
        static let maximumMarkerWidth: CGFloat = 4.0
    }

    // MARK: - Properties
    private var markerViews: [UIView] = []

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    // MARK: - Overrides
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customSize = CGSize(width: bounds.size.width, height: Constants.height)
        let customOrigin = CGPoint(x: bounds.origin.x, y: bounds.origin.y + Constants.height / 2)
        let customBounds = CGRect(origin: customOrigin, size: customSize)
        return customBounds
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let customOrigin = CGPoint(x: rect.origin.x, y: rect.origin.y - Constants.verticalOffset)
        let customRect = CGRect(origin: customOrigin, size: rect.size)
        return super.thumbRect(forBounds: bounds, trackRect: customRect, value: value)
    }
}

// MARK: - Setup
extension RRSlider {
    private func setup() {
        setThumbImage(Image.BuildRobot.currentBuildStepIndicator, for: .normal)
    }
}

// MARK: - Public methods
extension RRSlider {
    func markValues(_ values: [Int]) {
        setNeedsLayout()
        layoutIfNeeded()
        markerViews.forEach({ $0.removeFromSuperview() })
        markerViews = values.map { valueIndex -> UIView in
            let view = createMarkerView(on: trackRect(forBounds: bounds), index: valueIndex)
            addSubview(view)
            view.layer.zPosition = Constants.zPosition
            return view
        }
    }
}

// MARK: - Private methods
extension RRSlider {
    private func createMarkerView(on trackRect: CGRect, index: Int) -> UIView {
        let itemWidth = trackRect.size.width / CGFloat(maximumValue)
        var xOrigin = trackRect.origin.x + CGFloat(index) * CGFloat(itemWidth)
        if itemWidth >= Constants.maximumMarkerWidth {
            xOrigin -= Constants.maximumMarkerWidth / 2
        }
        let rect = CGRect(x: xOrigin,
                          y: trackRect.origin.y,
                          width: min(itemWidth, Constants.maximumMarkerWidth),
                          height: Constants.height)
        let view = UIView(frame: rect)
        view.backgroundColor = .white
        return view
    }
}
