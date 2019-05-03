//
//  RRZoomableImageView.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RRZoomableImageView: UIScrollView {
    // MARK: - Constants
    private enum Constants {
        static let minimumZoomScale: CGFloat = 0.5
        static let maximumZoomScale: CGFloat = 3.0
    }

    // MARK: - Properties
    let imageView = UIImageView(frame: .zero)

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        delegate = self

        minimumZoomScale = Constants.minimumZoomScale
        maximumZoomScale = Constants.maximumZoomScale

        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
}

// MARK: - UIScrollViewDelegate
extension RRZoomableImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
