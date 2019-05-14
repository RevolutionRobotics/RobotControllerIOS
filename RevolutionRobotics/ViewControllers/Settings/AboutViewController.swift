//
//  AboutApplicationViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 10..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class AboutViewController: BaseViewController {
    // MARK: - Constants
    enum Constants {
        static let termsAndConditions = URL(string: "https://www.revolutionrobotics.org/termsandconditions")!
        static let privacyPolicy = URL(string: "https://www.revolutionrobotics.org/privacypolicy")!
        static let website = URL(string: "https://www.revolutionrobotics.org/")!

        static let lineWidth: CGFloat = 2.0
        static let radius: CGFloat = 5.0
    }

    // MARK: - SocialNetwork
    enum SocialNetwork {
        case instagram
        case facebook

        var appBaseUrl: URL {
            switch self {
            case .instagram:
                return URL(string: "instagram://user?screen_name=RevoRobotics")!
            case .facebook:
                return URL(string: "facebook://user?screen_name=RevoRobotics")!
            }
        }

        var appWebUrl: URL {
            switch self {
            case .instagram:
                return URL(string: "https://www.instagram.com/RevoRobotics")!
            case .facebook:
                return URL(string: "https://facebook.com/RevoRobotics")!
            }
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var facebookButton: RRButton!
    @IBOutlet private weak var webButton: RRButton!
    @IBOutlet private weak var instagramButton: RRButton!
    @IBOutlet private weak var permissionsView: UIView!
    @IBOutlet private weak var permissionsLabel: UILabel!
    @IBOutlet private weak var permissionsInfoLabel: UILabel!
    @IBOutlet private weak var termsAndConditionsButton: UIButton!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var devInfoButton: UIButton!
}

// MARK: - View lifecycle
extension AboutViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: SettingsKeys.About.title.translate(), delegate: self)
        versionLabel.text = SettingsKeys.About.version.translate(args: Bundle.main.appVersion)
        permissionsLabel.text = SettingsKeys.About.permissionsTitle.translate()
        permissionsInfoLabel.text = SettingsKeys.About.permissionsInstruction.translate()
        privacyPolicyButton.setTitle(SettingsKeys.About.privacyPolicyButton.translate(), for: .normal)
        termsAndConditionsButton.setTitle(SettingsKeys.About.termsAndConditionsButton.translate(), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        facebookButton.setBorder(fillColor: . clear,
                                 strokeColor: .white,
                                 lineWidth: Constants.lineWidth,
                                 radius: Constants.radius,
                                 croppedCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        webButton.setBorder(fillColor: . clear,
                            strokeColor: .white,
                            lineWidth: Constants.lineWidth,
                            radius: Constants.radius,
                            croppedCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        instagramButton.setBorder(fillColor: . clear,
                                  strokeColor: .white,
                                  lineWidth: Constants.lineWidth,
                                  radius: Constants.radius,
                                  croppedCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        permissionsView.setBorder(fillColor: .clear, strokeColor: Color.blackTwo)
        termsAndConditionsButton.setBorder(fillColor: .clear,
                                           strokeColor: .white,
                                           lineWidth: Constants.lineWidth,
                                           croppedCorners: [.topRight])
        privacyPolicyButton.setBorder(fillColor: .clear,
                                      strokeColor: .white,
                                      lineWidth: Constants.lineWidth,
                                      croppedCorners: [.bottomLeft])
    }
}

// MARK: - Functions
extension AboutViewController {
    private func open(socialNetwork: SocialNetwork) {
        if UIApplication.shared.canOpenURL(socialNetwork.appBaseUrl) {
            UIApplication.shared.open(socialNetwork.appBaseUrl, options: [:], completionHandler: nil)
        } else {
            presentSafariModal(presentationFinished: nil, url: socialNetwork.appWebUrl)
        }
    }
}

// MARK: - Event handlers
extension AboutViewController {
    @IBAction private func facebookButtonTapped(_ sender: Any) {
        open(socialNetwork: .facebook)
    }

    @IBAction private func instagramButtonTapped(_ sender: Any) {
        open(socialNetwork: .instagram)
    }

    @IBAction private func webButtonTapped(_ sender: Any) {
        presentSafariModal(presentationFinished: nil, url: Constants.website)
    }

    @IBAction private func termsAndConditionsButtonTapped(_ sender: Any) {
        presentSafariModal(presentationFinished: nil, url: Constants.termsAndConditions)
    }

    @IBAction private func privacyPolicyButtonTapped(_ sender: Any) {
        presentSafariModal(presentationFinished: nil, url: Constants.privacyPolicy)
    }

    @IBAction private func permissionsButtonTapped(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
}
