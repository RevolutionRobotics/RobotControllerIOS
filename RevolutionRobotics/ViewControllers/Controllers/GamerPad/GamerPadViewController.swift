//
//  DriveMeViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 07..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SpriteKit

final class GamerPadViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var joystickContainer: SKView!

    @IBOutlet private weak var centerLeftButton: GamerPadButton!
    @IBOutlet private weak var centerRightButton: GamerPadButton!

    @IBOutlet private weak var actionLeftButton: GamerPadButton!
    @IBOutlet private weak var actionRightButton: GamerPadButton!
    @IBOutlet private weak var actionTopButton: GamerPadButton!
    @IBOutlet private weak var actionBottomButton: GamerPadButton!
}

// MARK: View lifecycle
extension GamerPadViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: RobotsKeys.Controllers.Play.screenTitle.translate(), delegate: self)
        setupJoystickScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
    }
}

// MARK: - Setup
extension GamerPadViewController {
    private func setupJoystickScene() {
        let joystickScene = JoystickScene()
        joystickScene.positionChanged = { position in
            print("Position = \(position)")
        }

        joystickContainer.presentScene(joystickScene)
    }

    private func setupButtons() {
        centerLeftButton.setup(title: "Center Left") {
            print("Center Left button tapped")
        }

        centerRightButton.setup(title: "Center Right") {
            print("Center Right button tapped")
        }

        actionLeftButton.setup(title: "Action Left") {
            print("Action Left button tapped")
        }

        actionRightButton.setup(title: "Action Right") {
            print("Action Right button tapped")
        }

        actionTopButton.setup(title: "Action Top") {
            print("Action Top button tapped")
        }

        actionBottomButton.setup(title: "Action Bottom") {
            print("Action Bottom button tapped")
        }
    }
}
