//
//  ProgramsOrderViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramsOrderViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var programsTableView: UITableView!
    @IBOutlet private weak var doneButton: UIButton!

    // MARK: - Variables
    var realmService: RealmServiceInterface!
    var programs: [ProgramDataModel] = [] {
        didSet {
            programsTableView.reloadData()
        }
    }

    // MARK: - Callbacks
    var doneCallback: CallbackType<[ProgramDataModel]>?
}

// MARK: - View lifecycle
extension ProgramsOrderViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ProgramsKeys.programOrderTitle.translate(), delegate: self)
        doneButton.setTitle(CommonKeys.done.translate(), for: .normal)
        programsTableView.dataSource = self
        programsTableView.dragDelegate = self
        programsTableView.dropDelegate = self
        programsTableView.dragInteractionEnabled = true
        programsTableView.register(ProgramsOrderTableViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        programs = realmService.getPrograms()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        programsTableView.reloadData()
    }
}

// MARK: - UITableViewDragDelegate
extension ProgramsOrderViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }

    private func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let program = programs[indexPath.row]
        let itemProvider = NSItemProvider(object: program.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = program
        return [dragItem]
    }

    func tableView(_ tableView: UITableView,
                   dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }

    func tableView(_ tableView: UITableView,
                   dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
}

// MARK: - UITableViewDropDelegate
extension ProgramsOrderViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }

    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension ProgramsOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramsOrderTableViewCell = programsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(with: programs[indexPath.row], order: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let program = programs[sourceIndexPath.row]
        programs.remove(at: sourceIndexPath.row)
        programs.insert(program, at: destinationIndexPath.row)
    }
}

// MARK: - Action handlers
extension ProgramsOrderViewController {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        doneCallback?(programs)
    }
}
