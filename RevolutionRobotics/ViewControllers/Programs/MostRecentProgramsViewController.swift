//
//  MostRecentProgramsViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class MostRecentProgramsViewController: BaseViewController, Dismissable {
    // MARK: - Constant
    private enum Constants {
        static let buttonFont = Font.jura(size: 12.0, weight: .bold)
        static let firstFiveProgamRange = 0...4
        static let firstFourProgamRange = 0...3
        static let animationDuration: TimeInterval = 0.25
    }

    // MARK: - Outlets
    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private weak var bottomContainer: UIView!
    @IBOutlet private weak var buttonContainer: UIStackView!
    @IBOutlet private weak var showMoreButton: RRButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var buttons: [RRButton]!

    // MARK: - Properties
    var programSelected: CallbackType<ProgramDataModel>?
    var dismissed: Callback?
    var showMoreTapped: Callback?
    private var programs: [ProgramDataModel] = []
    private var selectedProgram: ProgramDataModel?
    private let programSorter = ProgramSorter()
}

// MARK: - View lifecycle
extension MostRecentProgramsViewController {
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
extension MostRecentProgramsViewController {
    func setup(programs: [ProgramDataModel], selectedProgram: ProgramDataModel?) {
        self.programs = programSorter.sort(programs: programs, by: .date, order: .descending)
        if self.programs.isEmpty {
            self.programs = []
        } else {
            if selectedProgram == nil {
                if self.programs.count >= 5 {
                    self.programs = Array(self.programs[Constants.firstFiveProgamRange])
                } else {
                    self.programs = Array(self.programs[0...])
                }
            } else {
                if self.programs.count >= 4 {
                    self.programs = [selectedProgram!] + Array(self.programs[Constants.firstFourProgamRange])
                } else {
                    self.programs = Array(self.programs[0...])
                }
            }
        }

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

        if programs.count < buttons.count {
            let startIndex = programs.count
            buttons[startIndex...].forEach({ $0.isHidden = true })
        }

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
extension MostRecentProgramsViewController {
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
