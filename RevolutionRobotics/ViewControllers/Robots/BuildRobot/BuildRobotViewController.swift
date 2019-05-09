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
    var remoteRobotDataModel: Robot? {
        didSet {
            fetchBuildSteps()
        }
    }
    var storedRobotDataModel: UserRobot?
    private var steps: [BuildStep] = []
    private var currentStep: BuildStep?
    private let partView = PartView.instatiate()
}

// MARK: - View lifecycle
extension BuildRobotViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupStackView()
        navigationBar.setup(title: remoteRobotDataModel?.name, delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !steps.isEmpty else { return }
        refreshViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !steps.isEmpty else { return }
        setupProgressBar()
    }
}

// MARK: - Setup
extension BuildRobotViewController {
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
                let driveMeScreen = AppContainer.shared.container.unwrappedResolve(DriveMeViewController.self)
                self?.navigationController?.pushViewController(driveMeScreen, animated: true)
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
        let tipsModal = FailedConnectionTipsModal.instatiate()
        tipsModal.communityCallback = { [weak self] in
            self?.presentCommunityModal(presentationFinished: { [weak self] in
                guard let milestone = self?.currentStep?.milestone else {
                    return
                }
                self?.setupChapterFinishedModal(with: milestone)
            })
        }
        tipsModal.skipCallback = { [weak self] in
            self?.dismissViewController()
            self?.buildProgressBar.milestoneFinished()
        }
        tipsModal.tryAgainCallback = { [weak self] in
            self?.showTestingModal(with: milestone)
        }
        presentModal(with: tipsModal)
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
                id: remoteRobotDataModel!.id,
                buildStatus: .inProgress,
                actualBuildStep: step,
                lastModified: Date(),
                configId: remoteRobotDataModel!.configurationId,
                customName: remoteRobotDataModel?.name,
                customImage: nil,
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
