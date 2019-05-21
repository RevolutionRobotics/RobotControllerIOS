//
//  PlayablePadView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SpriteKit

typealias PressedPadButton = (index: Int, pressed: Bool)

protocol PlayablePadView: UIView {
    var horizontalPositionChanged: CallbackType<CGFloat>? { get set }
    var verticalPositionChanged: CallbackType<CGFloat>? { get set }
    var buttonTapped: CallbackType<PressedPadButton>? { get set }

    func configure(programs: [Program?])
}

extension PlayablePadView {
    func handlePositionChange(position: CGPoint) {
        horizontalPositionChanged?(position.x)
        verticalPositionChanged?(position.y)
    }

    func connectButtonHandling(at index: Int, program: Program, to button: PadButton) {
        button.setup(title: program.name) { [weak self] pressed in
            self?.buttonTapped?((index: index, pressed: pressed))
        }
    }

    func setupJoystickScene(in container: SKView) {
        let joystickScene = JoystickScene()
        joystickScene.positionChanged = handlePositionChange
        joystickScene.returnedToDefaultPosition = handlePositionChange
        container.presentScene(joystickScene)
        container.allowsTransparency = true
    }
}
