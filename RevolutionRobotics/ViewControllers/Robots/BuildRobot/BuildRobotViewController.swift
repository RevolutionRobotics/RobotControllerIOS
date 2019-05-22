//
//  BuildRobotViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class BuildRobotViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var progressLabel: RRProgressLabel!
    @IBOutlet private weak var bluetoothButton: RRButton!
    @IBOutlet private weak var partStackView: UIStackView!
    @IBOutlet private weak var buildProgressBar: BuildProgressBar!
    @IBOutlet private weak var zoomableImageView: RRZoomableImageView!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var bluetoothService: BluetoothServiceInterface!
    var remoteRobotDataModel: Robot? {
        didSet {
            fetchBuildSteps()
        }
    }
    var storedRobotDataModel: UserRobot?
    private var steps: [BuildStep] = []
    private var currentStep: BuildStep?
    private let partView = PartView.instatiate()
    @IBAction private func bluetoothButtonTapped(_ sender: RRButton) {
        guard !bluetoothService.hasConnectedDevice else { return }

        let modalPresenter = BluetoothConnectionModalPresenter()
        modalPresenter.present(
            on: self,
            startDiscoveryHandler: { [weak self] in
                self?.bluetoothService.startDiscovery(onScanResult: { result in
                    switch result {
                    case .success(let devices):
                        modalPresenter.discoveredDevices = devices
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })

            },
            deviceSelectionHandler: { [weak self] device in
                self?.bluetoothService.connect(to: device)
            },
            nextStep: nil)
    }
}

// MARK: - View lifecycle
extension BuildRobotViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStackView()
        setupBluetoothButton()
        navigationBar.setup(title: remoteRobotDataModel?.name, delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForConnectionChange()

        guard !steps.isEmpty else { return }
        refreshViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !steps.isEmpty else { return }
        setupProgressBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeFromConnectionChange()
    }
}

// MARK: - Setup
extension BuildRobotViewController {
    private func setupBluetoothButton() {
        let image =
            bluetoothService.hasConnectedDevice ? Image.Common.bluetoothIcon : Image.Common.bluetoothInactiveIcon
        bluetoothButton.setImage(image, for: .normal)
    }

    private func setupComponents() {
        setupPartsView()
        setupProgressLabel()
    }

    private func setupProgressLabel() {
        if let actualBuildStep = storedRobotDataModel?.actualBuildStep {
            progressLabel.currentStep = actualBuildStep + 1
        } else {
            progressLabel.currentStep = 1
        }
        progressLabel.numberOfSteps = steps.count
    }

    private func setupProgressBar() {
        buildProgressBar.numberOfSteps = steps.count - 1
        buildProgressBar.currentStep = storedRobotDataModel?.actualBuildStep ?? 0
        buildProgressBar.markers = steps
            .filter({ $0.milestone != nil })
            .map({ steps.firstIndex(of: $0) })
            .compactMap({ $0 })
        buildProgressBar.valueDidChange = { [weak self] currentStepIndex in
            guard self?.currentStep != self?.steps[currentStepIndex] else { return }
            self?.currentStep = self?.steps[currentStepIndex]
            self?.progressLabel.currentStep = currentStepIndex + 1
            self?.zoomableImageView.imageView.downloadImage(googleStorageURL: self?.currentStep?.image)
            self?.setupPartsView()
            self?.updateStoredRobot(step: currentStepIndex)
        }
        buildProgressBar.buildFinished = { [weak self] in
            let buildFinishedModal = BuildFinishedModal.instatiate()
            buildFinishedModal.homeCallback = { [weak self] in
                if let currentStep = self?.currentStep {
                    self?.updateStoredRobot(step: currentStep.stepNumber)
                }
                self?.popToRootViewController(animated: true)
            }
            buildFinishedModal.driveCallback = { [weak self] in
                if let currentStep = self?.currentStep {
                    self?.updateStoredRobot(step: currentStep.stepNumber)
                }
                self?.dismissViewController()
                let playController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
                self?.firebaseService.getController(
                    for: "0",
                    completion: { [weak self] result in
                        switch result {
                        case .success(let controller):
                            playController.controllerType = controller.type
                            self?.navigationController?.pushViewController(playController, animated: true)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                })
            }
            self?.presentModal(with: buildFinishedModal)
        }
        buildProgressBar.showMilestone = { [weak self] in
            guard let milestone = self?.currentStep?.milestone else {
                self?.buildProgressBar.milestoneFinished()
                return
            }
            self?.setupChapterFinishedModal(with: milestone)
        }
    }

    private func setupStackView() {
        partStackView.addArrangedSubview(partView)
        partStackView.setBorder(strokeColor: Color.brownishGrey,
                                showTopArrow: true,
                                croppedCorners: [.topRight, .bottomLeft])
        view.bringSubviewToFront(partStackView)
    }

    private func setupChapterFinishedModal(with milestone: Milestone) {
        let chapterFinishedModal = ChapterFinishedModal.instatiate()
        chapterFinishedModal.homeButtonTapped = { [weak self] in
            self?.popToRootViewController(animated: true)
        }
        chapterFinishedModal.testLaterButtonTapped = { [weak self] in
            self?.dismissViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        chapterFinishedModal.testNowButtonTapped = { [weak self] in
            self?.showTestingModal(with: milestone)
        }
        presentModal(with: chapterFinishedModal)
    }

    private func showTestingModal(with milestone: Milestone) {
        dismissViewController()
        let testingModal = TestingModal.instatiate()
        testingModal.positiveButtonTapped = { [weak self] in
            self?.dismissViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        testingModal.negativeButtonTapped = { [weak self] in
            self?.showTipsModal(with: milestone)
        }
        presentModal(with: testingModal)
    }

    private func showTipsModal(with milestone: Milestone) {
        dismissViewController()
        let tips = TipsModalView.instatiate()
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = "Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat."
        tips.skipTitle = ModalKeys.Tips.skipTesting.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()

        tips.communityCallback = { [weak self] in
            self?.presentSafariModal(presentationFinished: { [weak self] in
                guard let milestone = self?.currentStep?.milestone else {
                    return
                }
                self?.setupChapterFinishedModal(with: milestone)
            })
        }
        tips.skipCallback = { [weak self] in
            self?.dismissViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        tips.tryAgainCallback = { [weak self] in
            self?.showTestingModal(with: milestone)
        }
        presentModal(with: tips)
    }
}

// MARK: - Private methods
extension BuildRobotViewController {
    private func fetchBuildSteps() {
        firebaseService.getBuildSteps(for: remoteRobotDataModel?.id, completion: { [weak self] result in
            switch result {
            case .success(let steps):
                self?.steps = steps
                self?.currentStep = steps[self?.storedRobotDataModel?.actualBuildStep ?? 0]
                guard let loaded = self?.isViewLoaded, loaded == true else { return }
                self?.refreshViews()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    private func setupPartsView() {
        partView.setup(with: currentStep)
        partView.isLast = true
    }

    private func updateStoredRobot(step: Int) {
        guard let robot = storedRobotDataModel else {
            storedRobotDataModel = UserRobot(
                id: UUID().uuidString,
                remoteId: remoteRobotDataModel!.id,
                buildStatus: .inProgress,
                actualBuildStep: step,
                lastModified: Date(),
                configId: remoteRobotDataModel!.configurationId,
                customName: remoteRobotDataModel?.name,
                customImage: remoteRobotDataModel?.coverImageGSURL,
                customDescription: nil)
            realmService.saveRobot(storedRobotDataModel!, shouldUpdate: true)
            return
        }
        realmService.updateObject {
            robot.actualBuildStep = step >= self.steps.count ? step - 1 : step
            robot.lastModified = Date()
            robot.buildStatus = step >= self.steps.count ?
                BuildStatus.completed.rawValue : BuildStatus.inProgress.rawValue
        }
    }

    private func refreshViews() {
        setupComponents()
        let imagePath = steps[storedRobotDataModel?.actualBuildStep ?? 0].image
        zoomableImageView.imageView.downloadImage(googleStorageURL: imagePath)
    }
}

// MARK: - Bluetooth connection
extension BuildRobotViewController {
    override func connected() {
        dismissViewController()
        let connectionModal = ConnectionModal.instatiate()
        presentModal(with: connectionModal.successful)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.dismissViewController()
        }
        bluetoothButton.setImage(Image.Common.bluetoothIcon, for: .normal)
    }

    override func disconnected() {
        bluetoothButton.setImage(Image.Common.bluetoothInactiveIcon, for: .normal)
    }
}
