//
//  BuildRobotViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import os

class BuildRobotViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var progressLabel: RRProgressLabel!
    @IBOutlet private weak var partStackView: UIStackView!
    @IBOutlet private weak var buildProgressBar: BuildProgressBar!
    @IBOutlet private weak var pagerView: PagerView!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var remoteRobotDataModel: Robot? {
        didSet {
            steps = remoteRobotDataModel?.buildSteps ?? []
        }
    }
    var onboardingInProgress = false
    var storedRobotDataModel: UserRobot?
    private var oneSitting = true
    private var steps: [BuildStep] = []
    private var currentStep: BuildStep?
    private let partView = PartView.instatiate()
    private let partView2 = PartView.instatiate()
    private var milestone: Milestone?

    override func backButtonDidTap() {
        guard onboardingInProgress else {
            navigationController?.pop(to: YourRobotsViewController.self)
            return
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - View lifecycle
extension BuildRobotViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStackView()
        setupBluetoothButton()
        navigationBar.setup(title: remoteRobotDataModel?.name.text, delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !steps.isEmpty else { return }
        refreshViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !steps.isEmpty else { return }
        if storedRobotDataModel == nil { updateStoredRobot(step: 0) }
        setupProgressBar()
    }
}

// MARK: - Setup
extension BuildRobotViewController {
    private func setupBluetoothButton() {
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
    }

    private func setupComponents() {
        setupPartsView()
        setupProgressLabel()
    }

    private func setupProgressLabel() {
        if let actualBuildStep = storedRobotDataModel?.actualBuildStep {
            progressLabel.currentStep = actualBuildStep + 1
            oneSitting = false
        } else {
            progressLabel.currentStep = 1
        }
        progressLabel.numberOfSteps = steps.count
    }

    private func setupProgressBar() {
        let storedBuildStep = storedRobotDataModel?.actualBuildStep ?? 0
        buildProgressBar.numberOfSteps = steps.count - 1
        buildProgressBar.currentStep = storedBuildStep
        pagerView.items = steps.map({ $0.image })

        pagerView.imageInsets = UIEdgeInsets(
            top: navigationBar.frame.size.height,
            left: 0,
            bottom: buildProgressBar.frame.size.height,
            right: 0)

        pagerView.selectItem(at: storedBuildStep, animated: false)
        pagerView.pageSelectedCallback = { [weak self] index in
            guard let `self` = self else { return }
            self.buildProgressBar.currentStep = index
            self.progressLabel.currentStep = index + 1
        }

        buildProgressBar.markers = steps
            .filter({ $0.milestone != nil })
            .map({ steps.firstIndex(of: $0) })
            .compactMap({ $0 })
        buildProgressBar.valueDidChange = { [weak self] currentStepIndex in
            guard let `self` = self else { return }
            guard self.currentStep != self.steps[currentStepIndex] else {
                return
            }
            self.currentStep = self.steps[currentStepIndex]
            self.pagerView.selectItem(at: currentStepIndex)
            self.progressLabel.currentStep = currentStepIndex + 1

            self.setupPartsView()
            self.updateStoredRobot(step: currentStepIndex)
        }
        buildProgressBar.buildFinished = { [weak self] in
            guard let `self` = self else { return }
            let buildFinishedModal = BuildFinishedModalView.instatiate()
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
                self?.dismissModalViewController()
                self?.navigateToPlayViewController()
            }
            self.presentModal(with: buildFinishedModal, closeHidden: true)
            self.logEvent(named: "finish_basic_robot", params: [
                "id": self.remoteRobotDataModel?.id ?? "Unknown",
                "one_sitting": self.oneSitting
            ])
        }
        buildProgressBar.showMilestone = { [weak self] in
            guard let milestone = self?.currentStep?.milestone else {
                self?.buildProgressBar.milestoneFinished()
                return
            }
            self?.setupChapterFinishedModal(with: milestone)
        }
    }

    private func navigateToPlayViewController() {
        guard let configId = storedRobotDataModel?.configId,
            let configuration = realmService.getConfiguration(id: configId),
            let controller = realmService.getController(id: configuration.controller) else { return }

        let playViewController = AppContainer.shared.container.unwrappedResolve(PlayControllerViewController.self)
        playViewController.controllerDataModel = controller
        playViewController.robotName = storedRobotDataModel?.customName
        playViewController.onboardingInProgress = onboardingInProgress

        guard !onboardingInProgress else {
            navigationController?.pushViewController(playViewController, animated: true)
            return
        }

        var viewControllers = [navigationController!.viewControllers[0]]
        viewControllers.append(playViewController)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }

    private func setupStackView() {
        partStackView.addArrangedSubview(partView)
        partStackView.addArrangedSubview(partView2)
        view.bringSubviewToFront(partStackView)
    }

    private func setupChapterFinishedModal(with milestone: Milestone) {
        let chapterFinishedModal = ChapterFinishedModalView.instatiate()
        chapterFinishedModal.testLaterButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        chapterFinishedModal.testNowButtonTapped = { [weak self] in
            if self?.bluetoothService.connectedDevice != nil {
                self?.bluetoothService.testKit(
                    data: milestone.testCode.base64Decoded!,
                    onCompleted: nil)
                self?.showTestingModal(with: milestone)
            } else {
                self?.dismissModalViewController()
                self?.presentConnectModal()
                self?.milestone = milestone
            }
        }
        presentModal(with: chapterFinishedModal)
    }

    private func showTestingModal(with milestone: Milestone) {
        dismissModalViewController()
        let testingModal = TestingModalView.instatiate()
        testingModal.setup(with: .milestone(milestone))
        testingModal.positiveButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        testingModal.negativeButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            self?.showTipsModal(with: milestone)
        }
        presentModal(with: testingModal)
    }

    private func showTipsModal(with milestone: Milestone) {
        let tips = TipsModalView.instatiate()
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = ModalKeys.Tips.tips.translate()
        tips.skipTitle = ModalKeys.Tips.skipTesting.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()

        tips.communityCallback = { [weak self] in
            self?.openSafari(presentationFinished: { [weak self] in
                guard let milestone = self?.currentStep?.milestone else {
                    return
                }
                self?.setupChapterFinishedModal(with: milestone)
            })
        }
        tips.skipCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        tips.tryAgainCallback = { [weak self] in

            self?.bluetoothService.testKit(
                data: milestone.testCode.base64Decoded!,
                onCompleted: nil)
            self?.showTestingModal(with: milestone)
        }
        presentModal(with: tips)
    }
}

// MARK: - Private methods
extension BuildRobotViewController {
    private func presentDisconnectModal() {
        let view = DisconnectModalView.instatiate()
        view.disconnectHandler = { [weak self] in
            self?.bluetoothService.disconnect(shouldReconnect: false)
            self?.dismissModalViewController()
        }
        view.cancelHandler = { [weak self] in
            self?.dismissModalViewController()
        }
        presentModal(with: view)
    }

    private func presentBluetoothConnectionModal(buttonTapped: Bool = true) {
        guard bluetoothService.connectedDevice != nil else {
            presentConnectModal()
            return
        }

        guard buttonTapped else {
            return
        }

        presentDisconnectModal()
    }

    private func setupPartsView() {
        if currentStep?.partImage == nil && currentStep?.partImage2 == nil {
            partStackView.isHidden = true
            return
        }
        partStackView.isHidden = false
        partView.setup(with: currentStep?.partImage)
        if let partImage2 = currentStep?.partImage2 {
            partView2.isHidden = false
            partView2.setup(with: partImage2)
            partView2.isLast = true
            partView.isLast = false
        } else {
            partView2.setup(with: nil)
            partView2.isHidden = true
            partView.isLast = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        partStackView.setBorder(strokeColor: Color.brownishGrey,
                                showTopArrow: true,
                                croppedCorners: [.topRight, .bottomLeft])
    }

    private func createNewRobot(step: Int) {
        guard let remoteRobot = remoteRobotDataModel else { return }

        let robotId = UUID().uuidString
        let configId = UUID().uuidString

        let savedPrograms = realmService.getPrograms()
        let remotePrograms = remoteRobot.programs
            .compactMap({ ProgramDataModel(program: $0, robotId: robotId) })

        let storedController = ControllerDataModel(controller: remoteRobot.controller, localConfigurationId: configId)
        let storedPortMapping = PortMappingDataModel(remoteMapping: remoteRobot.portMapping)
        let storedConfiguration = ConfigurationDataModel(
            id: configId,
            controller: storedController.id,
            mapping: storedPortMapping)

        storedRobotDataModel = UserRobot(
            id: robotId,
            remoteId: remoteRobot.id,
            buildStatus: .inProgress,
            actualBuildStep: step,
            lastModified: Date(),
            configId: configId,
            customName: remoteRobot.name.text,
            customImage: remoteRobot.coverImage,
            customDescription: remoteRobot.description.text)

        guard let storedRobot = storedRobotDataModel else { return }

        realmService.savePrograms(programs: savedPrograms + remotePrograms)
        realmService.saveControllers([storedController])
        realmService.saveConfigurations([storedConfiguration])
        realmService.saveRobot(storedRobot, shouldUpdate: true)

        logEvent(named: "start_basic_robot", params: [
            "id": robotId
        ])

        if onboardingInProgress {
            UserDefaults.standard.set(true, forKey: UserDefaults.Keys.revvyBuilt)
        }
    }

    private func updateStoredRobot(step: Int) {
        guard let robot = storedRobotDataModel else {
            createNewRobot(step: step)
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
    }
}

// MARK: - Action
extension BuildRobotViewController {
    @IBAction private func bluetoothButtonTapped(_ sender: RRButton) {
        presentBluetoothConnectionModal()
    }
}

// MARK: - Bluetooth connection
extension BuildRobotViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func robotSoftwareApproved() {
        super.robotSoftwareApproved()
        if let milestone = milestone {
            bluetoothService.testKit(
                data: milestone.testCode.base64Decoded!,
                onCompleted: nil)
            self.milestone = nil
        }
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }

    override func connectionError() {
        let connectionModal = ConnectionModalView.instatiate()
        dismissModalViewController()
        presentModal(with: connectionModal.failed)

        connectionModal.skipConnectionButtonTapped = { [weak self] in
            self?.dismissModalViewController()
        }
        connectionModal.tryAgainButtonTapped = { [weak self] in
            self?.dismissAndTryAgain()
        }

        connectionModal.tipsButtonTapped = { [weak self] in
            self?.dismissModalViewController()
            let failedConnectionTipsModal = TipsModalView.instatiate()
            failedConnectionTipsModal.skipTitle = ModalKeys.Connection.failedConnectionSkipButton.translate()
            failedConnectionTipsModal.skipCallback = { [weak self] in
                self?.dismissModalViewController()
            }
            failedConnectionTipsModal.tryAgainCallback = self?.dismissAndTryAgain
            failedConnectionTipsModal.communityCallback = {
                self?.openSafari(presentationFinished: { [weak self] in
                    self?.dismissAndTryAgain()
                })
            }
            self?.presentModal(with: failedConnectionTipsModal)
        }
    }

    private func dismissAndTryAgain() {
        dismissModalViewController()
        presentBluetoothConnectionModal()
    }
}
