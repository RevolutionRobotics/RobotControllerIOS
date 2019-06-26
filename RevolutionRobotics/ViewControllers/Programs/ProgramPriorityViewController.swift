//
//  ProgramPriorityViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RealmSwift

final class ProgramPriorityViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var programsTableView: UITableView!
    @IBOutlet private weak var doneButton: UIButton!

    // MARK: - Variables
    var realmService: RealmServiceInterface!

    // MARK: - Callbacks
    var controllerViewModel: ControllerViewModel? {
        didSet {
            guard let controllerViewModel = controllerViewModel else { return }
            orderedPrograms = controllerViewModel.priorityOrderedPrograms
            drivetrainPlaceholder = ProgramDataModel()
            orderedPrograms.insert(drivetrainPlaceholder, at: controllerViewModel.joystickPriority)
        }
    }
    private var orderedPrograms: [ProgramDataModel] = []
    private var drivetrainPlaceholder: ProgramDataModel!
}

// MARK: - View lifecycle
extension ProgramPriorityViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: ProgramsKeys.programOrderTitle.translate(), delegate: self)
        doneButton.setTitle(CommonKeys.done.translate(), for: .normal)
        programsTableView.dataSource = self
        programsTableView.dragDelegate = self
        programsTableView.dropDelegate = self
        programsTableView.dragInteractionEnabled = true
        programsTableView.register(ProgramsOrderTableViewCell.self)

        drivetrainPlaceholder.id = "-1"
        drivetrainPlaceholder.name = "DRIVETRAIN PLACEHOLDER"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        doneButton.setBorder(fillColor: .clear, strokeColor: .white)
        programsTableView.reloadData()
    }
}

// MARK: - UITableViewDragDelegate
extension ProgramPriorityViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: indexPath)
    }

    private func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let program = orderedPrograms[indexPath.row]
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
extension ProgramPriorityViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }

    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension ProgramPriorityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedPrograms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramsOrderTableViewCell = programsTableView.dequeueReusableCell(forIndexPath: indexPath)
        let program = orderedPrograms[indexPath.row]
        cell.setup(with: program,
                   order: indexPath.row + 1,
                   isButtonlessProgram: (controllerViewModel?.isBackgroundProgram(program))!)
        cell.infoCallback = { [weak self] in
            let modal = ProgramInfoModal.instatiate()
            modal.configure(
                program: program,
                infoType: .info,
                issue: nil,
                editButtonHandler: nil,
                actionButtonHandler: { [weak self] _ in
                    self?.dismissModalViewController()
            })
            self?.presentModal(with: modal)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let program = orderedPrograms[sourceIndexPath.row]
        orderedPrograms.remove(at: sourceIndexPath.row)
        orderedPrograms.insert(program, at: destinationIndexPath.row)
    }
}

// MARK: - Update, save data
extension ProgramPriorityViewController {
    private func saveController(name: String?, description: String?) {
        guard let controller = realmService.getController(id: controllerViewModel?.id) else {
            let newController = ControllerDataModel(id: controllerViewModel?.id,
                                                    configurationId: controllerViewModel!.configurationId,
                                                    type: (controllerViewModel?.type)!.rawValue,
                                                    mapping: ControllerButtonMappingDataModel())
            realmService.saveControllers([newController])
            saveController(name: name, description: description)
            return
        }

        realmService.saveProgramBindings((controllerViewModel?.backgroundProgramBindings)!)

        realmService.updateObject(closure: { [weak self] in
            controller.name = name!
            controller.controllerDescription = description ?? ""
            controller.lastModified = Date()
            controller.joystickPriority =
                (self?.orderedPrograms.firstIndex(of: (self?.drivetrainPlaceholder)!))!

            let viewModel = self?.controllerViewModel
            self?.updateButtonProgramPriority(on: viewModel?.b1Binding, controller: controller, buttonIndex: 1)
            self?.updateButtonProgramPriority(on: viewModel?.b2Binding, controller: controller, buttonIndex: 2)
            self?.updateButtonProgramPriority(on: viewModel?.b3Binding, controller: controller, buttonIndex: 3)
            self?.updateButtonProgramPriority(on: viewModel?.b4Binding, controller: controller, buttonIndex: 4)
            self?.updateButtonProgramPriority(on: viewModel?.b5Binding, controller: controller, buttonIndex: 5)
            self?.updateButtonProgramPriority(on: viewModel?.b6Binding, controller: controller, buttonIndex: 6)
            controller.backgroundProgramBindings.removeAll()
            viewModel?.backgroundProgramBindings.forEach { [weak self] backgroundProgramBinding in
                self?.updatePriority(of: backgroundProgramBinding)
                controller.backgroundProgramBindings.append(backgroundProgramBinding)
            }
        })

        if let configuration = realmService.getConfiguration(id: controllerViewModel?.configurationId),
            configuration.controller.isEmpty {
            realmService.updateObject(closure: {
                configuration.controller = controller.id
            })
        }

        if let robot = realmService.getRobots().first(where: { $0.configId == controllerViewModel?.configurationId }),
            robot.buildStatus != BuildStatus.completed.rawValue {
            realmService.updateObject(closure: {
                robot.buildStatus = BuildStatus.completed.rawValue
            })
        }
    }

    private func updatePriority(of programBinding: ProgramBindingDataModel?) {
        guard let programBinding = programBinding else { return }
        let program = orderedPrograms.first(where: { $0.id == programBinding.programId }) ??
            orderedPrograms.first(where: { $0.remoteId == programBinding.programId })
        let prio = Int(orderedPrograms.firstIndex(of: program!)!)
        programBinding.priority = prio
    }

    //swiftlint:disable cyclomatic_complexity
    private func updateButtonProgramPriority(on programBinding: ProgramBindingDataModel?,
                                             controller: ControllerDataModel,
                                             buttonIndex: Int) {
        guard let programBinding = programBinding else {
            switch buttonIndex {
            case 1:
                controller.mapping?.b1 = nil
            case 2:
                controller.mapping?.b2 = nil
            case 3:
                controller.mapping?.b3 = nil
            case 4:
                controller.mapping?.b4 = nil
            case 5:
                controller.mapping?.b5 = nil
            case 6:
                controller.mapping?.b6 = nil
            default:
                break
            }
            return
        }

        updatePriority(of: programBinding)
        switch buttonIndex {
        case 1:
            controller.mapping?.b1 = programBinding
        case 2:
            controller.mapping?.b2 = programBinding
        case 3:
            controller.mapping?.b3 = programBinding
        case 4:
            controller.mapping?.b4 = programBinding
        case 5:
            controller.mapping?.b5 = programBinding
        case 6:
            controller.mapping?.b6 = programBinding
        default:
            break
        }
    }
}

// MARK: - Action handlers
extension ProgramPriorityViewController {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        let saveModal = SaveModal.instatiate()
        saveModal.type = .controller
        saveModal.name = controllerViewModel?.name
        saveModal.descriptionTitle = controllerViewModel?.customDesctiprion
        saveModal.saveCallback = { [weak self] (data: SaveModal.SaveData) in
            self?.saveController(name: data.name, description: data.description)
            self?.dismissModalViewController()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        presentModal(with: saveModal)
    }
}
