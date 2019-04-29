//
//  AvailableRobotsView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class AvailableRobotsView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var availableRobotsTableView: UITableView!
    @IBOutlet private weak var infoLabel: UILabel!
}

// MARK: - View lifecycle
extension AvailableRobotsView {
    override func awakeFromNib() {
        super.awakeFromNib()

        availableRobotsTableView.register(AvailableRobotsTableViewCell.self)
        availableRobotsTableView.delegate = self
        availableRobotsTableView.dataSource = self

        infoLabel.text = RobotsKeys.WhoToBuild.searchingForRobotsTitle.translate()
    }
}

// MARK: - UITableViewDelegate
extension AvailableRobotsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

// MARK: - UITableViewDataSource
extension AvailableRobotsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AvailableRobotsTableViewCell = availableRobotsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(with: "Robot \(indexPath.row + 1) ID")
        return cell
    }
}
