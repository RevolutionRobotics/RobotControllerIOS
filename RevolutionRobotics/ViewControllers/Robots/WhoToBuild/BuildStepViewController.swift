//
//  BuildStepViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import EFImageViewZoom

final class BuildStepViewController: BaseViewController, EFImageViewZoomDelegate {
    @IBOutlet private weak var imageView: EFImageViewZoom!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView._delegate = self
        imageView.contentModeImageView = .center
    }
}
