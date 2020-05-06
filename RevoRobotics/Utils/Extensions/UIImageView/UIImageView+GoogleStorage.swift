//
//  UIImageView+GoogleStorage.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Kingfisher
import os

extension UIImageView {
    func downloadImage(from imageUrl: String?, grayScaled: Bool = false) {
        guard let imageUrl = imageUrl else { return }

        if ImageCache.default.isCached(forKey: imageUrl) {
            retrieveImageFromCache(key: imageUrl, grayScaled: grayScaled)
        } else {
            guard let url = URL(string: imageUrl) else { return }

            let resource = ImageResource(downloadURL: url, cacheKey: imageUrl)
            kf.setImage(with: resource, placeholder: nil, options: [.targetCache(ImageCache.default)])

            if grayScaled {
                image = image?.noir
            }

            resetZoom()
        }
    }
}

// MARK: - Private extensions
extension UIImageView {
    private func retrieveImageFromCache(key: String, grayScaled: Bool) {
        ImageCache.default.retrieveImageInDiskCache(
            forKey: key,
            completionHandler: { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.image = grayScaled ? image?.noir : image
                        self?.resetZoom()
                    }
                case .failure:
                    os_log("Error: Could not fetch image from cache!")
                }
        })
    }

    private func resetZoom() {
        guard let superView = superview as? RRZoomableImageView else { return }
        superView.resetZoom()
    }
}
