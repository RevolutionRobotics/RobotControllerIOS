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
    // MARK: - Constants
    enum Constants {
        static let tableViewTopInset: CGFloat = 30
    }

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
            orderedPrograms.insert(drivetrainPlaceholder,
                                   at: min(controllerViewModel.joystickPriority, orderedPrograms.count))
        }
    }
    private var orderedPrograms: [ProgramDataModel] = []
    private var drivetrainPlaceholder: ProgramDataModel!
    private var sourceIndexPath: IndexPath?
    private var destinationIndexPath: IndexPath?
}

// MARK: - View lifecycle
extension ProgramPriorityViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected

        navigationBar.setup(title: ProgramsKeys.programOrderTitle.translate(), delegate: self)
        doneButton.setTitle(CommonKeys.done.translate(), for: .normal)
        programsTableView.dataSource = self
        programsTableView.dragDelegate = self
        programsTableView.dropDelegate = self
        programsTableView.dragInteractionEnabled = true
        programsTableView.register(ProgramsOrderTableViewCell.self)
        programsTableView.contentInset = UIEdgeInsets(top: Constants.tableViewTopInset, left: 0, bottom: 0, right: 0)

        drivetrainPlaceholder.id = "-1"
        drivetrainPlaceholder.name = "Drivetrain"
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
        sourceIndexPath = indexPath
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
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let sourceIndexPath = sourceIndexPath, let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        moveItem(from: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        self.destinationIndexPath = destinationIndexPath
        return UITableViewDropProposal(operation: .move, intent: .automatic)
    }

    func tableView(_ tableView: UITableView, dropSessionDidExit session: UIDropSession) {
        guard let sourceIndexPath = sourceIndexPath, var destinationIndexPath = destinationIndexPath else {
            return
        }
        if destinationIndexPath.row > sourceIndexPath.row {
            destinationIndexPath = IndexPath(row: orderedPrograms.count - 1, section: 0)
        } else {
            destinationIndexPath = IndexPath(row: 0, section: 0)
        }
        moveItem(from: sourceIndexPath, to: destinationIndexPath)
        programsTableView.scrollToRow(at: destinationIndexPath, at: .none, animated: true)
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
        let infoCallback = { [weak self] in
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
        cell.setup(
            with: program,
            order: indexPath.row + 1,
            isButtonlessProgram: (controllerViewModel?.isBackgroundProgram(program))!,
            infoCallback: program.id == drivetrainPlaceholder.id ? nil : infoCallback
        )

        return cell
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

    private func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let program = orderedPrograms[sourceIndexPath.row]
        orderedPrograms.remove(at: sourceIndexPath.row)
        orderedPrograms.insert(program, at: destinationIndexPath.row)
        programsTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        self.sourceIndexPath = nil
        self.destinationIndexPath = nil
        programsTableView.reloadData()
    }
}

// MARK: - Action handlers
extension ProgramPriorityViewController {
    @IBAction private func doneButtonTapped(_ sender: Any) {
        let saveModal = SaveModal.instatiate()
        saveModal.type = .controller
        let name = (controllerViewModel?.name)!.isEmpty ?
            controllerViewModel?.type.displayName : controllerViewModel?.name
        saveModal.name = name
        saveModal.descriptionTitle = controllerViewModel?.customDesctiprion
        saveModal.saveCallback = { [weak self] (data: SaveModal.SaveData) in
            self?.saveController(name: data.name, description: data.description)
            self?.dismissModalViewController()
            self?.navigationController?.pop(to: RobotConfigurationViewController.self)
        }
        presentModal(with: saveModal)
    }
}

// MARK: - Bluetooth connection
extension ProgramPriorityViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}
