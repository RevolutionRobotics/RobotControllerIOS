//
//  UIButton+BackgroundColor.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.from(color: color), for: state)
    }
}
