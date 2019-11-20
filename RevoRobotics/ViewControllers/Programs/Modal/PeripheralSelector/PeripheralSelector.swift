//
//  PeripheralSelector.swift
//  RevolutionRobotics
//
//  Created by Pável Áron on 2019. 11. 12..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class PeripheralSelector: UIView {
    // MARK: - Constants
    private enum Constants {
        static let rowHeight: CGFloat = 60.0
    }

    // MARK: - Properties
    var items: [String]?
    var selectedIndex: Int?
    var callback: CallbackType<Int>?

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyLabel: UILabel!
}

// MARK: - Setup
extension PeripheralSelector {
    func setup(titled title: String, emptyText: String) {
        titleLabel.text = title
        emptyLabel.text = emptyText
        tableView.register(PeripheralTableViewCell.self)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.isHidden = (items ?? []).isEmpty
        emptyLabel.isHidden = !tableView.isHidden
    }
}

// MARK: - UITableViewDataSource
extension PeripheralSelector: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PeripheralTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

        let index = indexPath.row
        if let items = items {
            cell.setup(with: items[index])
            cell.setSelectedState(index == selectedIndex)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}

// MARK: - UITableViewDelegate
extension PeripheralSelector: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback?(indexPath.row)
    }
}
