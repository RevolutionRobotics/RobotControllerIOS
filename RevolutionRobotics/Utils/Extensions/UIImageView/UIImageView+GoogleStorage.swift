//
//  UIImageView+GoogleStorage.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 25..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import os

extension UIImageView {
    func downloadImage(googleStorageURL: String?) {
        guard let googleStorageURL = googleStorageURL else { return }

        if ImageCache.default.isCached(forKey: googleStorageURL) {
            retrieveImageFromCache(key: googleStorageURL)
        } else {
            fetchImageFromFirebase(googleStorageURL: googleStorageURL)
        }
    }
}

// MARK: - Private extensions
extension UIImageView {
    private func fetchImageFromFirebase(googleStorageURL: String) {
        self.kf.indicatorType = .activity
        (self.kf.indicator?.view as? UIActivityIndicatorView)?.color = .white
        getImageURL(of: googleStorageURL) { [weak self] result in
            switch result {
            case .success(let imageURL):
                let resource = ImageResource(downloadURL: imageURL, cacheKey: googleStorageURL)
                self?.kf.setImage(with: resource, placeholder: nil, options: [.targetCache(ImageCache.default)])
            case .failure:
                os_log("Error: Could not fetch image from Firebase!")
                self?.image = Image.Common.imagePlaceholder
            }
        }
    }

    private func getImageURL(of googleStorageURL: String, completion: CallbackType<Result<URL, FirebaseError>>?) {
        Storage.storage().reference(forURL: googleStorageURL).downloadURL { url, error in
            guard error == nil else {
                completion?(.failure(FirebaseError.imageURLDownloadFailed(error!.localizedDescription)))
                return
            }

            guard let url = url else {
                completion?(.failure(FirebaseError.invalidImageURL))
                return
            }

            completion?(.success(url))
        }
    }

    private func retrieveImageFromCache(key: String) {
        ImageCache.default.retrieveImageInDiskCache(
            forKey: key,
            completionHandler: { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                case .failure:
                    os_log("Error: Could not fetch image from cache!")
                }
        })
    }
}
