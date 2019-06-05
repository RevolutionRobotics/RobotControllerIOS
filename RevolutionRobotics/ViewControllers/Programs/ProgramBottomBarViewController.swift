//
//  ProgramBottomBarViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramBottomBarViewController: BaseViewController {
    // MARK: - Constant
    private enum Constants {
        static let buttonFont = Font.jura(size: 12.0, weight: .bold)
        static let firstFiveProgamRange = 0...4
    }

    // MARK: - Outlets
    @IBOutlet private weak var buttonContainer: UIStackView!
    @IBOutlet private weak var showMoreButton: RRButton!

    // MARK: - Callbacks
    var programSelected: CallbackType<Program>?
    var dismissed: Callback?
    var showMoreTapped: Callback?

    // MARK: - Variables
    private var programs: [Program] = []
    private var selectedProgram: Program?
    private let programSorter = ProgramSorter()
}

// MARK: - View lifecycle
extension ProgramBottomBarViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupShowMoreButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupButtonsData()
        setupButtonsLayout()
    }
}

// MARK: - Setup
extension ProgramBottomBarViewController {
    func setup(programs: [Program], selectedProgram: Program?) {
        self.programs = programSorter.sort(programs: programs, by: .date, order: .descending)
        self.programs = Array(self.programs[Constants.firstFiveProgamRange])

        if let selectedProgram = selectedProgram,
            let selectedIndex = self.programs.firstIndex(of: selectedProgram) {
            self.selectedProgram = selectedProgram
            self.programs.remove(at: selectedIndex)
            self.programs.insert(selectedProgram, at: 0)
        }
    }

    private func setupShowMoreButton() {
        showMoreButton.titleLabel?.textAlignment = .center
        showMoreButton.setTitle(ProgramsKeys.MostRecent.showMore.translate(), for: .normal)
    }

    private func setupButtonsLayout() {
        buttonContainer.arrangedSubviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalTo: showMoreButton.widthAnchor).isActive = true
            $0.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
        }
        showMoreButton.setBorder(fillColor: .clear, strokeColor: .white)

        if selectedProgram != nil {
            buttonContainer.arrangedSubviews.first?.setBorder(
                fillColor: Color.black,
                strokeColor: .red,
                croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft]
            )
        }
    }

    private func setupButtonsData() {
        programs.map(makeButton).forEach(buttonContainer.addArrangedSubview)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func makeButton(from program: Program) -> RRButton {
        let button = RRButton()
        button.backgroundColor = Color.blackTwo
        button.titleLabel?.font = Constants.buttonFont
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = .white
        button.setTitle(program.name, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }
}

// MARK: - Event handlers
extension ProgramBottomBarViewController {
    @objc private func buttonTapped(_ sender: RRButton) {
        guard let buttons = buttonContainer.arrangedSubviews as? [RRButton],
            let buttonIndex = buttons.firstIndex(of: sender) else { return }
        programSelected?(programs[buttonIndex])
    }

    @IBAction private func showMoreTapped(_ sender: Any) {
        showMoreTapped?()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        dismissed?()
    }
}
