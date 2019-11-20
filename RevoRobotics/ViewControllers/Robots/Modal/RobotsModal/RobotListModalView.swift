//
//  RobotListModalView.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 06..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class RobotListModalView: UIView {
    // MARK: - Constants
    enum Constants {
        static let shadowHeight: CGFloat = 70
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var robotsTableView: UITableView!

    // MARK: - Variables
    var selectedRobotCallback: CallbackType<UserRobot>?
    private var robots: [UserRobot] = [] {
        didSet {
            robotsTableView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension RobotListModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        robotsTableView.delegate = self
        robotsTableView.dataSource = self
        robotsTableView.register(RobotSelectorTableViewCell.self)
        titleLabel.text = RobotsKeys.YourRobots.select.translate().uppercased()
        addShadow()
    }
}

// MARK: - Setup
extension RobotListModalView {
    func setup(with programs: [UserRobot]) {
        let asd = programs.sorted(by: { $0.lastModified > $1.lastModified })
        self.robots = asd
    }
}

// MARK: - Private functions
extension RobotListModalView {
    private func addShadow() {
        let shadowLayer = CAGradientLayer()
        shadowLayer.frame = CGRect(x: 0,
                                   y: frame.height - Constants.shadowHeight,
                                   width: frame.width,
                                   height: Constants.shadowHeight)
        shadowLayer.colors = [Color.blackTwo.cgColor, UIColor.clear.cgColor]
        shadowLayer.startPoint = CGPoint(x: 0, y: 1)
        shadowLayer.endPoint = CGPoint(x: 0, y: 0)
        self.layer.addSublayer(shadowLayer)
    }
}

// MARK: - UITableViewDataSource
extension RobotListModalView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return robots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RobotSelectorTableViewCell = robotsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(robot: robots[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RobotListModalView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRobotCallback?(robots[indexPath.row])
    }
}
