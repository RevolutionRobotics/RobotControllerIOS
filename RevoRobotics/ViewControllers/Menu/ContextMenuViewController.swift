//
//  ContextMenuViewController.swift
//  RevoRobotics
//
//  Created by Pável Áron on 2020. 02. 07..
//  Copyright © 2020. Revolution Robotics. All rights reserved.
//

import UIKit

typealias ContextMenuItem = (title: String, handler: Callback)

final class ContextMenuViewController: UITableViewController {
    // MARK: - Constants
    enum Constants {
        static let cellIdentifier = "contextMenuCell"
        static let contextMenuWidth: CGFloat = 250.0
        static let menuItemFontSize: CGFloat = 17.0
    }

    // MARK: - Properties
    var rows: [ContextMenuItem]?
}

// MARK: - Lifecycle methods
extension ContextMenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(
            width: Constants.contextMenuWidth,
            height: tableView.contentSize.height)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
    }
}

// MARK: - UITableViewDataSource
extension ContextMenuViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIdentifier,
            for: indexPath)
        let highlightView = UIView()
        highlightView.backgroundColor = Color.white16

        cell.textLabel?.text = rows?[indexPath.row].title
        cell.textLabel?.font = Font.jura(size: Constants.menuItemFontSize)
        cell.textLabel?.textColor = .white
        cell.selectedBackgroundView = highlightView
        cell.backgroundColor = .clear

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContextMenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: rows?[indexPath.row].handler)
    }
}
