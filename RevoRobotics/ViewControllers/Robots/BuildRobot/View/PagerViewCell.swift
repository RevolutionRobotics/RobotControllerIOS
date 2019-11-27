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

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        zoomableImageView.frame = contentView.frame
        zoomableImageView.imageView.frame = contentView.frame
        addSubview(zoomableImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
extension PagerViewCell {
    func setup(with url: String) {
        zoomableImageView.resetZoom()
        zoomableImageView.imageView.downloadImage(googleStorageURL: url)
    }
}
