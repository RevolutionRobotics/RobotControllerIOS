//
//  ProgramBottomBarViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramBottomBarViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private var buttons: [RRButton]!
    @IBOutlet private weak var showMoreButton: RRButton!

    // MARK: - Callbacks
    var buttonCallback: CallbackType<Program>?
    var showMoreCallback: Callback?

    // MARK: - Variables
    private var programs: [Program] = []
    private var programSelected: Bool = false
}

// MARK: - View lifecycle
extension ProgramBottomBarViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in buttons {
            button.titleLabel?.textAlignment = .center
        }
        showMoreButton.titleLabel?.textAlignment = .center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupButtons()
    }
}

// MARK: - Setup
extension ProgramBottomBarViewController {
    func setup(programs: [Program], programSelected: Bool = false) {
        self.programs = programs
        self.programSelected = programSelected
    }

    private func setupButtons() {
        setupCorners()
        setupTitles()
    }

    private func setupCorners() {
        for button in buttons {
            button.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
        }
        if programSelected {
            buttons[0].setBorder(fillColor: Color.black,
                                 strokeColor: .red,
                                 croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
        }
        showMoreButton.setBorder(fillColor: .clear, strokeColor: .white)
    }

    private func setupTitles() {
        for (index, button) in buttons.enumerated() where index < programs.count {
            button.setTitle(programs[index].name, for: .normal)
        }
    }
}

// MARK: - Event handlers
extension ProgramBottomBarViewController {
    @IBAction private func button1Tapped(_ sender: Any) {
        // buttonCallback?(selectedProgram)
    }

    @IBAction private func button2Tapped(_ sender: Any) {
        // buttonCallback?(selectedProgram)
    }

    @IBAction private func button3Tapped(_ sender: Any) {
        // buttonCallback?(selectedProgram)
    }

    @IBAction private func button4Tapped(_ sender: Any) {
        // buttonCallback?(selectedProgram)
    }

    @IBAction private func button5Tapped(_ sender: Any) {
        // buttonCallback?(selectedProgram)
    }

    @IBAction private func showMoreTapped(_ sender: Any) {
        showMoreCallback?()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        dismissViewController()
    }
}
