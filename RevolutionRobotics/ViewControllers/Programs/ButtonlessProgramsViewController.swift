//
//  ButtonlessProgramsViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ButtonlessProgramsViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var programsTableView: UITableView!
    @IBOutlet private weak var noProgramsLabel: UILabel!
    @IBOutlet private weak var nextButton: RRButton!
    @IBOutlet private weak var dateButton: UIButton!
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet private weak var compatibleButton: UIButton!
    @IBOutlet private weak var selectAllButton: UIButton!

    // MARK: - Variables
    var realmService: RealmServiceInterface!
    var configurationId: String?
    var controllerViewModel: ControllerViewModel? {
        didSet {
            selectedPrograms = controllerViewModel?.backgroundPrograms ?? []
            if isViewLoaded {
                programsTableView.reloadData()
            }
        }
    }
    private var allPrograms: [ProgramDataModel] = []
    private var configurationVariableNames: [String] = []
    private var selectedPrograms: [ProgramDataModel] = []
    private var filteredAndOrderedPrograms: [ProgramDataModel] = [] {
        didSet {
            programsTableView.reloadData()
        }
    }
    private let programSorter = ProgramSorter()
    private var programSortingOptions = ProgramSorter.Options(field: .name, order: .ascending) {
        didSet {
            filteredAndOrderedPrograms = programSorter.sort(programs: filteredAndOrderedPrograms,
                                                            options: programSortingOptions)
        }
    }
}

// MARK: - View lifecycle
extension ButtonlessProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ProgramsKeys.Buttonless.title.translate(), delegate: self)
        selectAllButton.setTitle(ProgramsKeys.Buttonless.selectAll.translate(), for: .normal)
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        nextButton.superview?.setNeedsLayout()
        nextButton.superview?.layoutIfNeeded()
        programsTableView.dataSource = self
        programsTableView.delegate = self
        programsTableView.register(ButtonlessProgramTableViewCell.self)
        fetchPrograms()
        configurationVariableNames = realmService.getConfiguration(id: configurationId)?.mapping?.variableNames ?? []
    }

    private func fetchPrograms() {
        let programs = Set(realmService.getPrograms())
        let prohibited = Set(controllerViewModel?.buttonPrograms ?? [])
        updatePrograms(Array(programs.subtracting(prohibited)))
        compatibleButton.setTitle(ProgramsKeys.Buttonless.showCompatible.translate(), for: .normal)
        compatibleButton.setImage(Image.Programs.Buttonless.CompatibleIcon, for: .normal)
        compatibleButton.isSelected = false
    }

    private func updatePrograms(_ programs: [ProgramDataModel]) {
        allPrograms = programs
        if compatibleButton.isSelected {
            let variableNames = Set(configurationVariableNames)
            let compatiblePrograms = allPrograms.filter({ Set($0.variableNames).isSubset(of: variableNames) })
            filteredAndOrderedPrograms =
                programSorter.sort(programs: compatiblePrograms, options: programSortingOptions)
        } else {
            filteredAndOrderedPrograms = programSorter.sort(programs: allPrograms, options: programSortingOptions)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextButton.setBorder(fillColor: .clear, strokeColor: .white)
        programsTableView.isHidden = filteredAndOrderedPrograms.isEmpty
        noProgramsLabel.isHidden = !filteredAndOrderedPrograms.isEmpty
        programsTableView.reloadData()
    }

    private func isProgramCompatible(_ program: ProgramDataModel) -> Bool {
        let variableNames = realmService.getConfiguration(id: configurationId)?.mapping?.variableNames ?? []
        return Set(program.variableNames).isSubset(of: Set(variableNames))
    }
}

// MARK: - UITableViewDataSource
extension ButtonlessProgramsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAndOrderedPrograms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ButtonlessProgramTableViewCell =
            programsTableView.dequeueReusableCell(forIndexPath: indexPath)
        let program = filteredAndOrderedPrograms[indexPath.row]
        cell.setup(with: program)
        cell.infoCallback = { [weak self] in
            let modal = ProgramInfoModal.instatiate()
            let isCompatible = (self?.isProgramCompatible(program))!
            modal.configure(
                program: program,
                infoType: .incompatible,
                issue: isCompatible ? nil : ModalKeys.Program.compatibilityIssue.translate(),
                editButtonHandler: { [weak self] in
                    self?.dismissModalViewController()
                    let vc = AppContainer.shared.container.unwrappedResolve(ProgramsViewController.self)
                    vc.selectedProgram = program
                    self?.navigationController?.pushViewController(vc, animated: true)
                }, actionButtonHandler: { [weak self] _ in
                    self?.dismissModalViewController()
            })
            self?.presentModal(with: modal)
        }
        if !isProgramCompatible(program) {
            cell.update(state: .incompatible)
        } else {
            if selectedPrograms.contains(program) {
                cell.update(state: .selected)
            } else {
                cell.update(state: .available)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDataSource
extension ButtonlessProgramsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ButtonlessProgramTableViewCell,
            isProgramCompatible(filteredAndOrderedPrograms[indexPath.row]) else { return }

        if cell.state == .available {
            cell.update(state: .selected)
            selectedPrograms.append(filteredAndOrderedPrograms[indexPath.row])
        } else {
            cell.update(state: .available)
            selectedPrograms.removeAll(where: { $0 == filteredAndOrderedPrograms[indexPath.row] })
        }
    }
}

// MARK: - Action handlers
extension ButtonlessProgramsViewController {
    @IBAction private func compatibleButtonTapped(_ sender: UIButton) {
        compatibleButton.isSelected.toggle()
        if compatibleButton.isSelected {
            let variableNames = Set(configurationVariableNames)
            let compatiblePrograms = allPrograms.filter({ Set($0.variableNames).isSubset(of: variableNames) })
            filteredAndOrderedPrograms =
                programSorter.sort(programs: compatiblePrograms, options: programSortingOptions)
            compatibleButton.setTitle(ProgramsKeys.Buttonless.showAll.translate(), for: .normal)
            compatibleButton.setImage(Image.Programs.Buttonless.CompatibleIconAll, for: .normal)
        } else {
            filteredAndOrderedPrograms = programSorter.sort(programs: allPrograms, options: programSortingOptions)
            compatibleButton.setTitle(ProgramsKeys.Buttonless.showCompatible.translate(), for: .normal)
            compatibleButton.setImage(Image.Programs.Buttonless.CompatibleIcon, for: .normal)
        }
    }

    @IBAction private func selectAllButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            selectedPrograms = filteredAndOrderedPrograms
            sender.setImage(Image.Programs.Buttonless.checkboxChecked, for: .normal)
        } else {
            selectedPrograms = []
            sender.setImage(Image.Programs.Buttonless.checkboxNotChecked, for: .normal)
        }
        programsTableView.reloadData()
    }

    @IBAction private func nameButtonTapped(_ sender: UIButton) {
        nameButton.isSelected.toggle()
        dateButton.isSelected = true
        dateButton.setImage(Image.Programs.Buttonless.SortDateUp, for: .normal)
        programSortingOptions = ProgramSorter.Options(
            field: .name,
            order: nameButton.isSelected ? .ascending : .descending
        )
        if programSortingOptions.order == .ascending {
            nameButton.setImage(Image.Programs.Buttonless.SortNameUpSelected, for: .normal)
        } else {
            nameButton.setImage(Image.Programs.Buttonless.SortNameDownSelected, for: .normal)
        }
    }

    @IBAction private func dateButtonTapped(_ sender: UIButton) {
        dateButton.isSelected.toggle()
        nameButton.isSelected = false
        nameButton.setImage(Image.Programs.Buttonless.SortNameUp, for: .normal)
        programSortingOptions = ProgramSorter.Options(
            field: .date,
            order: dateButton.isSelected ? .ascending : .descending
        )
        if programSortingOptions.order == .ascending {
            dateButton.setImage(Image.Programs.Buttonless.SortDateUpSelected, for: .normal)
        } else {
            dateButton.setImage(Image.Programs.Buttonless.SortDateDownSelected, for: .normal)
        }
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        controllerViewModel?.backgroundPrograms = selectedPrograms.filter(isProgramCompatible)
        let vc = AppContainer.shared.container.unwrappedResolve(ProgramPriorityViewController.self)
        vc.controllerViewModel = controllerViewModel
        navigationController?.pushViewController(vc, animated: true)
    }
}
