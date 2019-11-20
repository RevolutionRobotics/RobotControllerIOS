//
//  AvailableRobotsTableViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class AvailableRobotsTableViewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var robotNameLabel: UILabel!
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var cropView: UIView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
}

// MARK: - View lifecycle
extension AvailableRobotsTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        cropView.setBorder(strokeColor: Color.brownGrey)
    }
}

// MARK: - Selection
extension AvailableRobotsTableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        loadingIndicator.isHidden = !selected
        if selected {
            loadingIndicator.startAnimating()
            cropView.setBorder(strokeColor: UIColor.white)
            leftView.backgroundColor = UIColor.white
        } else {
            loadingIndicator.stopAnimating()
            cropView.setBorder(strokeColor: Color.brownGrey)
            leftView.backgroundColor = Color.brownGrey
        }
    }
}

// MARK: - Setup
extension AvailableRobotsTableViewCell {
    func setup(with name: String) {
        self.robotNameLabel.text = name
    }
}
