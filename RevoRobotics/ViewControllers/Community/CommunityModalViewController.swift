//
//  CommunityModalViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 08..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SafariServices

final class CommunityModalViewController: SFSafariViewController {
    // MARK: - Properties
    var presentationFinished: Callback?
}

// MARK: - View lifecycle
extension CommunityModalViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
}

// MARK: - SFSafariViewControllerDelegate
extension CommunityModalViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        presentationFinished?()
    }
}
