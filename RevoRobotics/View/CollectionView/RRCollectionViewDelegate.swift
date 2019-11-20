//
//  RRCollectionViewDelegate.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

protocol RRCollectionViewDelegate: class {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func setButtons(rightHidden: Bool, leftHidden: Bool)
}

extension RRCollectionViewDelegate {
    func setButtons(rightHidden: Bool, leftHidden: Bool) {}
}
