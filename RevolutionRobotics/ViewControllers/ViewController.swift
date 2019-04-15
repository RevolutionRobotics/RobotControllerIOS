//
//  ViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 01..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NibLoadable {
    init() {
        super.init(nibName: type(of: self).nibName, bundle: Bundle(for: type(of: self)))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
