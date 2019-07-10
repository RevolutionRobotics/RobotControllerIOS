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
    private var programSortingOptions = ProgramSorter.Options(field: .date, order: .descending) {
        didSet {
             filteredAndOrderedPrograms = programSorter.sort(programs: allPrograms, options: programSortingOptions)
        }
    }

    private var allPrograms: [ProgramDataModel] = []
    private var filteredAndOrderedPrograms: [ProgramDataModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var realmService: RealmServiceInterface!
    var programSelected: CallbackType<ProgramDataModel>?
    var dismissedCallback: Callback?
    var configurationVariableNames: [String] = []
    var prohibitedPrograms: [ProgramDataModel] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNormalState()
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

    private func setupNormalState() {
        titleLabel.text = ProgramsKeys.Selector.title.translate()
        filterButton.setTitle(ProgramsKeys.Selector.showAllPrograms.translate(), for: .normal)
        filterButton.setImage(Image.Programs.filterIcon, for: .normal)
        nameSorterButton.setTitle(ProgramsKeys.Selector.orderByName.translate(), for: .normal)
        dateSorterButton.setTitle(ProgramsKeys.Selector.orderByDate.translate(), for: .normal)
    }

    private func setupButtonsSelectedState() {
        filterButton.setTitle(ProgramsKeys.Selector.showCompatiblePrograms.translate(), for: .selected)
        filterButton.setImage(Image.Programs.compatibleIcon, for: .selected)
        nameSorterButton.setImage(Image.Common.arrowUp, for: .selected)
        dateSorterButton.setImage(Image.Common.arrowDown, for: .selected)
    }

    private func setupButtonsInitialState() {
        filterButton.isSelected = true
        dateSorterButton.isSelected = true
        setDisabledState(for: nameSorterButton)
    }

    private func setDisabledState(for button: UIButton) {
        button.isSelected = false
        button.alpha = Constants.disabledAlphaValue
    }

    private func toggleEnabledState(for button: UIButton) {
        button.isSelected.toggle()
        button.alpha = Constants.enabledAlphaValue
    }
}

// MARK: - Programs
extension ProgramSelectorViewController {
    private func fetchPrograms() {
        let programs = Set(realmService.getPrograms())
        let prohibited = Set(prohibitedPrograms)
        updatePrograms(Array(programs.subtracting(prohibited)))
    }

    private func updatePrograms(_ programs: [ProgramDataModel]) {
        allPrograms = programs
        filterPrograms()
    }

    private func filterPrograms() {
        if !filterButton.isSelected {
            let variableNames = Set(configurationVariableNames)
            let compatiblePrograms = allPrograms.filter { Set($0.variableNames).isSubset(of: variableNames) }
            filteredAndOrderedPrograms = programSorter.sort(
                programs: compatiblePrograms,
                options: programSortingOptions
            )
        } else {
            filteredAndOrderedPrograms = programSorter.sort(programs: allPrograms, options: programSortingOptions)
        }
    }
}

// MARK: - UITableViewDelegate
extension ProgramSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        programSelected?(filteredAndOrderedPrograms[indexPath.row])
    }
}

// MARK: - UITableViewDataSource
extension ProgramSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAndOrderedPrograms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramSelectorTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(program: filteredAndOrderedPrograms[indexPath.row])
        return cell
    }
}

// MARK: - Actions
extension ProgramSelectorViewController {
    @IBAction private func backButtonTapped(_ sender: Any) {
        dismissedCallback?()
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func filterButtonTapped(_ sender: Any) {
        filterButton.isSelected.toggle()
        filterPrograms()
    }

    @IBAction private func nameSorterButtonTapped(_ sender: Any) {
        toggleEnabledState(for: nameSorterButton)
        setDisabledState(for: dateSorterButton)
        programSortingOptions = ProgramSorter.Options(
            field: .name,
            order: nameSorterButton.isSelected ? .ascending : .descending
        )
    }

    @IBAction private func dateSorterButtonTapped(_ sender: Any) {
        toggleEnabledState(for: dateSorterButton)
        setDisabledState(for: nameSorterButton)
        programSortingOptions = ProgramSorter.Options(
            field: .date,
            order: dateSorterButton.isSelected ? .descending : .ascending
        )
    }
}
