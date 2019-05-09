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

extension UIImageView {
    func downloadImage(googleStorageURL: String?) {
        guard let googleStorageURL = googleStorageURL else { return }

        getImageURL(of: googleStorageURL) { [weak self] result in
            switch result {
            case .success(let imageURL):
                self?.kf.indicatorType = .activity
                self?.kf.setImage(with: imageURL, placeholder: nil)
            case .failure(let failure):
                print("Image Download failed with error: \(failure)")
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
}
