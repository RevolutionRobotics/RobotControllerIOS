//
//  RRCustomView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 23..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class RRCustomView: UIView {
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addNib()
    }
}
