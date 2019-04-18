//
//  RRNavigationBar.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol RRNavigationBarDelegate: class {
    func backButtonDidTap()
}

final class RRNavigationBar: UIView, NibLoadable {
    // MARK: - Outlets
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Delegate
    private weak var delegate: RRNavigationBarDelegate? = nil {
        didSet {
            backButton.isHidden = delegate == nil
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
}

// MARK: - Setup
extension RRNavigationBar {
    func setup(title: String? = nil, delegate: RRNavigationBarDelegate? = nil) {
        titleLabel.text = title
        self.delegate = delegate
    }

    private func setupNib() {
        let bundle = Bundle(for: RRNavigationBar.self)
        let nib = UINib(nibName: RRNavigationBar.nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

        insertSubview(view, at: 0)
        view.heightAnchor.constraint(equalToConstant: 71.0).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

// MARK: - Actions
extension RRNavigationBar {
    @IBAction private func backButtonTapped(_ sender: Any) {
        delegate?.backButtonDidTap()
    }
}
