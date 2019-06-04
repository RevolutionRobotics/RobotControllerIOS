//
//  ProgramSelectorViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramSelectorViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let estimatedRowHeight: CGFloat = 54.0
        static let disabledAlphaValue: CGFloat = 0.6
        static let enabledAlphaValue: CGFloat = 1.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var nameSorterButton: UIButton!
    @IBOutlet private weak var dateSorterButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Properties
    private let programSorter = ProgramSorter()
    private var programSortingOptions = ProgramSorter.Options(field: .name, order: .ascending) {
        didSet {
             programs = programSorter.sort(programs: programs, options: programSortingOptions)
        }
    }

    private var programs: [Program] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var firebaseService: FirebaseServiceInterface!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTranslations()
        setupButtonsSelectedState()
        setupButtonsInitialState()
        fetchPrograms()
    }
}

// MARK: - Setup
extension ProgramSelectorViewController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProgramSelectorTableViewCell.self)
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
    }

    private func setupTranslations() {
        titleLabel.text = ProgramsKeys.Selector.title.translate()
        filterButton.setTitle(ProgramsKeys.Selector.showAllPrograms.translate(), for: .normal)
        nameSorterButton.setTitle(ProgramsKeys.Selector.orderByName.translate(), for: .normal)
        dateSorterButton.setTitle(ProgramsKeys.Selector.orderByDate.translate(), for: .normal)
    }

    private func setupButtonsSelectedState() {
        filterButton.setTitle(ProgramsKeys.Selector.showCompatiblePrograms.translate(), for: .selected)
        filterButton.setImage(Image.Programs.compatibleIcon, for: .selected)
        nameSorterButton.setImage(Image.Common.arrowUp, for: .selected)
        dateSorterButton.setImage(Image.Common.arrowUp, for: .selected)
    }

    private func setupButtonsInitialState() {
        filterButton.isSelected = true
        setEnabledState(for: nameSorterButton)
        setDisabledState(for: dateSorterButton)
    }

    private func setDisabledState(for button: UIButton) {
        button.isSelected = false
        button.alpha = Constants.disabledAlphaValue
    }

    private func setEnabledState(for button: UIButton) {
        button.isSelected.toggle()
        button.alpha = Constants.enabledAlphaValue
    }
}

// MARK: - Fetch
extension ProgramSelectorViewController {
    private func fetchPrograms() {
        firebaseService.getPrograms { [unowned self] result in
            switch result {
            case .success(let programs):
                self.programs = self.programSorter.sort(programs: programs, options: self.programSortingOptions)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ProgramSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected program = \(programs[indexPath.row].name)")
    }
}

// MARK: - UITableViewDataSource
extension ProgramSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramSelectorTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(program: programs[indexPath.row])
        return cell
    }
}

// MARK: - Actions
extension ProgramSelectorViewController {
    @IBAction private func backButtonTapped(_ sender: Any) {
        dismissViewController()
    }

    @IBAction private func filterButtonTapped(_ sender: Any) {
        filterButton.isSelected.toggle()
        print("show only compatible programs? \(filterButton.isSelected)")
    }

    @IBAction private func nameSorterButtonTapped(_ sender: Any) {
        setEnabledState(for: nameSorterButton)
        setDisabledState(for: dateSorterButton)
        programSortingOptions = ProgramSorter.Options(
            field: .name,
            order: nameSorterButton.isSelected ? .ascending : .descending
        )
    }

    @IBAction private func dateSorterButtonTapped(_ sender: Any) {
        setEnabledState(for: dateSorterButton)
        setDisabledState(for: nameSorterButton)
        programSortingOptions = ProgramSorter.Options(
            field: .date,
            order: dateSorterButton.isSelected ? .ascending : .descending
        )
    }
}