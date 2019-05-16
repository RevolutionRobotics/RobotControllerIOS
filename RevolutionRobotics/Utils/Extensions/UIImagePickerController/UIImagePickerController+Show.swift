//
//  UIImagePickerController+Show.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIImagePickerController {
    static func show(with delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate),
                     on viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌ Camera not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = .camera
        imagePicker.modalPresentationStyle = .currentContext
        imagePicker.allowsEditing = false
        viewController.present(imagePicker, animated: true)
    }
}
