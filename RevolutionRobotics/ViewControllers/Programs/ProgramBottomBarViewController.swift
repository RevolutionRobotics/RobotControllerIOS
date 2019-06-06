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
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Outlets
    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private weak var bottomContainer: UIView!
    @IBOutlet private weak var buttonContainer: UIStackView!
    @IBOutlet private weak var showMoreButton: RRButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var buttons: [RRButton]!

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

        emptyLabel.text = ProgramsKeys.MostRecent.empty.translate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupButtons()
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

    private func setupButtons() {
        guard !programs.isEmpty else {
            showMoreButton.setBorder(fillColor: .clear, strokeColor: .white)
            activityIndicator.stopAnimating()
            UIView.animate(withDuration: Constants.animationDuration) {
                self.showMoreButton.alpha = 1.0
                self.emptyLabel.alpha = 1.0
            }
            return
        }
        programs.enumerated().forEach { (index, program) in
            let button = buttons[index]
            button.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
            button.setTitle(program.name, for: .normal)
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.textAlignment = .center
        }

        let startIndex = programs.count - 1
        buttons[startIndex...].forEach({ $0.isHidden = true })

        showMoreButton.setBorder(fillColor: .clear, strokeColor: .white)

        if selectedProgram != nil {
            buttons.first?.setBorder(
                fillColor: Color.black,
                strokeColor: .red,
                croppedCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft]
            )
        }

        activityIndicator.stopAnimating()
        UIView.animate(withDuration: Constants.animationDuration) {
            self.showMoreButton.alpha = 1.0
            self.buttonContainer.alpha = 1.0
        }
    }
}

// MARK: - Event handlers
extension ProgramBottomBarViewController {
    @IBAction private func buttonTapped(_ sender: RRButton) {
        guard let buttonIndex = buttons.firstIndex(of: sender) else { return }
        programSelected?(programs[buttonIndex])
    }

    @IBAction private func showMoreTapped(_ sender: Any) {
        showMoreTapped?()
    }

    @IBAction private func backgroundTapped(_ sender: Any) {
        dismissed?()
    }
}
