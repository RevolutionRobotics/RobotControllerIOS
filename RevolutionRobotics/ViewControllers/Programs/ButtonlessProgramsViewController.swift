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
    private var compatiblePrograms: [ProgramDataModel] {
        return allPrograms.filter(isProgramCompatible)
    }
    private var selectedPrograms: [ProgramDataModel] = []
    private var filteredAndOrderedPrograms: [ProgramDataModel] = [] {
        didSet {
            updateEmptyStateVisibility()
            programsTableView.reloadData()
        }
    }
    private let programSorter = ProgramSorter()
    private var programSortingOptions = ProgramSorter.Options(field: .date, order: .descending) {
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
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        setupButtons()
        setupTableView()
        fetchPrograms()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextButton.setBorder(fillColor: .clear, strokeColor: .white)
        updateEmptyStateVisibility()
        programsTableView.reloadData()
    }
}

// MARK: - Setup
extension ButtonlessProgramsViewController {
    private func setupButtons() {
        setupSelectAllButton()
        setupNextButton()
        setupCompatibleButton()
        setupDateButton()
        setupNameButton()
        setupInitialSorting()
    }

    private func setupSelectAllButton() {
        selectAllButton.setTitle(ProgramsKeys.Buttonless.selectAll.translate(), for: .normal)
        selectAllButton.setImage(Image.Programs.Buttonless.checkboxChecked, for: .selected)
        selectAllButton.setImage(Image.Programs.Buttonless.checkboxNotChecked, for: .normal)
    }

    private func setupCompatibleButton() {
        compatibleButton.setTitle(ProgramsKeys.Buttonless.showAll.translate(), for: .selected)
        compatibleButton.setImage(Image.Programs.Buttonless.CompatibleIconAll, for: .selected)
        compatibleButton.setTitle(ProgramsKeys.Buttonless.showCompatible.translate(), for: .normal)
        compatibleButton.setImage(Image.Programs.Buttonless.CompatibleIcon, for: .normal)
        compatibleButton.isSelected = true
    }

    private func setupNextButton() {
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        nextButton.superview?.setNeedsLayout()
        nextButton.superview?.layoutIfNeeded()
    }

    private func setupInitialSorting() {
        dateButton.isSelected = programSortingOptions.field == .date
        nameButton.isSelected = programSortingOptions.field == .name

        programSortingOptions.field == .date ? resetNameButton() : resetDateButton()
    }

    private func setupDateButton() {
        dateButton.setImage(Image.Programs.Buttonless.SortDateUpSelected, for: .normal)
        dateButton.setImage(Image.Programs.Buttonless.SortDateDownSelected, for: .selected)
    }

    private func setupNameButton() {
        nameButton.setImage(Image.Programs.Buttonless.SortNameUpSelected, for: .selected)
        nameButton.setImage(Image.Programs.Buttonless.SortNameDownSelected, for: .normal)
    }

    private func setupTableView() {
        programsTableView.dataSource = self
        programsTableView.delegate = self
        programsTableView.register(ButtonlessProgramTableViewCell.self)
    }

    private func updateEmptyStateVisibility() {
        selectAllButton.isHidden = compatiblePrograms.isEmpty
        programsTableView.isHidden = filteredAndOrderedPrograms.isEmpty
        noProgramsLabel.isHidden = !filteredAndOrderedPrograms.isEmpty
    }

    private func resetNameButton() {
        nameButton.isSelected = false
        nameButton.setImage(Image.Programs.Buttonless.SortNameUp, for: .normal)
    }

    private func resetDateButton() {
        dateButton.isSelected = false
        dateButton.setImage(Image.Programs.Buttonless.SortDateUp, for: .normal)
    }
}

// MARK: - Program
extension ButtonlessProgramsViewController {
    private func fetchPrograms() {
        let programs = Set(realmService.getPrograms())
        let prohibited = Set(controllerViewModel?.buttonPrograms ?? [])
        updatePrograms(Array(programs.subtracting(prohibited)))
    }

    private func updatePrograms(_ programs: [ProgramDataModel]) {
        allPrograms = programs
        filteredAndOrderedPrograms = programSorter.sort(
            programs: compatibleButton.isSelected ? compatiblePrograms : allPrograms,
            options: programSortingOptions
        )
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
        filteredAndOrderedPrograms = programSorter.sort(
            programs: compatibleButton.isSelected ? compatiblePrograms : allPrograms,
            options: programSortingOptions
        )
    }

    @IBAction private func selectAllButtonTapped(_ sender: UIButton) {
        selectAllButton.isSelected.toggle()
        selectedPrograms = selectAllButton.isSelected ? filteredAndOrderedPrograms : []
        programsTableView.reloadData()
    }

    @IBAction private func nameButtonTapped(_ sender: UIButton) {
        nameButton.isSelected.toggle()
        setupNameButton()
        resetDateButton()
        programSortingOptions = ProgramSorter.Options(
            field: .name,
            order: nameButton.isSelected ? .ascending : .descending
        )
    }

    @IBAction private func dateButtonTapped(_ sender: UIButton) {
        dateButton.isSelected.toggle()
        setupDateButton()
        resetNameButton()
        programSortingOptions = ProgramSorter.Options(
            field: .date,
            order: dateButton.isSelected ? .descending : .ascending
        )
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        controllerViewModel?.backgroundPrograms = selectedPrograms.filter(isProgramCompatible)
        let vc = AppContainer.shared.container.unwrappedResolve(ProgramPriorityViewController.self)
        vc.controllerViewModel = controllerViewModel
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Bluetooth connection
extension ButtonlessProgramsViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
