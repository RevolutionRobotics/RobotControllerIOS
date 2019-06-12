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
    @IBOutlet private weak var compatibleLabel: UILabel!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet private weak var selectAllLabel: UILabel!

    // MARK: - Variables
    var realmService: RealmServiceInterface!
    private var programs: [ProgramDataModel] = [] {
        didSet {
            programsTableView.isHidden = programs.isEmpty
            noProgramsLabel.isHidden = !programs.isEmpty
            programsTableView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension ButtonlessProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ProgramsKeys.Buttonless.title.translate(), delegate: self)
        selectAllLabel.text = ProgramsKeys.Buttonless.selectAll.translate()
        compatibleLabel.text = ProgramsKeys.Buttonless.showCompatible.translate()
        nextButton.setTitle(CommonKeys.next.translate(), for: .normal)
        programsTableView.dataSource = self
        programsTableView.register(ButtonlessProgramTableViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextButton.setBorder(fillColor: .clear, strokeColor: .white)
        programs = realmService.getPrograms()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        programsTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ButtonlessProgramsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ButtonlessProgramTableViewCell =
            programsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(with: programs[indexPath.row])
        return cell
    }
}

// MARK: - Action handlers
extension ButtonlessProgramsViewController {
    @IBAction private func compatibleButtonTapped(_ sender: Any) {
    }

    @IBAction private func selectAllButtonTapped(_ sender: Any) {
    }

    @IBAction private func nameButtonTapped(_ sender: Any) {
    }

    @IBAction private func dateButtonTapped(_ sender: Any) {
    }

    @IBAction private func nextButtonTapped(_ sender: Any) {
    }
}
