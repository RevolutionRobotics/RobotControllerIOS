//
//  CommunityViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 08..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SafariServices

class CommunityViewController: SFSafariViewController {
    var presentationFinished: Callback?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
}

// MARK: - SFSafariViewControllerDelegate
extension CommunityViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        presentationFinished?()
    }
}
