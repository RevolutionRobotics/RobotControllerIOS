//
//  UIView+NibLoadable.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIView: NibLoadable {
    static var nibName: String {
        return String(describing: self)
    }
}

// MARK: - Public
extension UIView {
    static func instatiate() -> Self {
        return loadFromNib(nibType: self)
    }

    func addNib() {
        let view = loadViewWithOwner(nibType: type(of: self), owner: self)

        addSubview(view)
        sendSubviewToBack(view)
        view.anchorToSuperview()
    }
}

// MARK: - Private
extension UIView {
    // swiftlint:disable force_cast
    private static func loadFromNib<Nib: NibLoadable>(nibType: Nib.Type) -> Nib {
        let bundle = Bundle(for: nibType)
        let nib = UINib(nibName: nibType.nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! Nib

        return view
    }

    private func loadViewWithOwner<Nib: NibLoadable>(nibType: Nib.Type, owner: Any?) -> UIView {
        let bundle = Bundle(for: nibType)
        let nib = UINib(nibName: nibType.nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: owner, options: nil).first as! UIView

        return view
    }
    // swiftlint:enable force_cast
}
