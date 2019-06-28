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
        static let defaultZoomScale: CGFloat = 0.75
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

        imageView.contentMode = .scaleAspectFit
        zoomScale = Constants.defaultZoomScale
        addSubview(imageView)
    }
}

// MARK: - UIScrollViewDelegate
extension RRZoomableImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

// MARK: - ImageLayout
extension RRZoomableImageView {
    private func centerImage() {
        let boundsSize = self.bounds.size
        var contentsFrame = imageView.frame

        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }

        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }

        imageView.frame = contentsFrame
    }

    func resetZoom() {
        zoomScale = Constants.defaultZoomScale
        centerImage()
    }

    func resizeImageView() {
        imageView.frame = bounds
        centerImage()
    }
}
