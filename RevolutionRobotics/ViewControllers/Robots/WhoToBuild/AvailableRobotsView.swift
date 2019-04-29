//
//  AvailableRobotsView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import struct RevolutionRoboticsBluetooth.Device

final class AvailableRobotsView: UIView {
    // MARK: - Outlets
    @IBOutlet private weak var availableRobotsTableView: UITableView!
    @IBOutlet private weak var infoLabel: UILabel!

    // MARK: - Properties
    var selectionHandler: CallbackType<Device>?
    var discoveredDevices: [Device] = [] {
        didSet {
            if !discoveredDevices.isEmpty {
                availableRobotsTableView.backgroundView = nil
            }
            availableRobotsTableView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension AvailableRobotsView {
    override func awakeFromNib() {
        super.awakeFromNib()

        setupAvailableRobotsTableView()
        infoLabel.text = RobotsKeys.WhoToBuild.searchingForRobotsTitle.translate()

    }

    private func setupAvailableRobotsTableView() {
        availableRobotsTableView.register(AvailableRobotsTableViewCell.self)
        availableRobotsTableView.delegate = self
        availableRobotsTableView.dataSource = self

        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        availableRobotsTableView.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
    }
}

// MARK: - UITableViewDelegate
extension AvailableRobotsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionHandler?(discoveredDevices[indexPath.row])
    }
}

// MARK: - UITableViewDataSource
extension AvailableRobotsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AvailableRobotsTableViewCell = availableRobotsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.setup(with: discoveredDevices[indexPath.row].name)
        return cell
    }
}
