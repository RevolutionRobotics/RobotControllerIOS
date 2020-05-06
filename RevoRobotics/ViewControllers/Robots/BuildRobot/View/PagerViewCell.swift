//
//  PagerViewCell.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2019. 11. 27..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PagerViewCell: UICollectionViewCell {
    // MARK: - Properties
    private let zoomableImageView = RRZoomableImageView()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        zoomableImageView.frame = contentView.frame
        addSubview(zoomableImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension PagerViewCell {
    func setup(with url: String, imageInsets: UIEdgeInsets?) {
        zoomableImageView.resetZoom()
        zoomableImageView.imageView.downloadImage(from: url)

        setupInsets(with: imageInsets)
    }

    func setupSaved(with imageUrl: String, imageInsets: UIEdgeInsets?) {
        zoomableImageView.resetZoom()
        zoomableImageView.imageView.image = UIImage(contentsOfFile: imageUrl)

        setupInsets(with: imageInsets)
    }

    private func setupInsets(with imageInsets: UIEdgeInsets?) {
        let parentFrame = zoomableImageView.frame
        let insets = imageInsets ?? .zero

        zoomableImageView.imageView.frame = CGRect(
            x: parentFrame.minX + insets.left + UIView.notchSize,
            y: parentFrame.minY + insets.top,
            width: parentFrame.width
                - insets.left
                - insets.right
                - UIView.notchSize
                - UIView.safeAreaRight,
            height: parentFrame.height
                - insets.top
                - insets.bottom
                - UIView.safeAreaTop
                - UIView.safeAreaBottom)

        zoomableImageView.setNeedsLayout()
    }
}
