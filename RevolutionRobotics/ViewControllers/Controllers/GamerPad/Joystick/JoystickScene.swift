//
//  JoystickScene.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import SpriteKit

final class JoystickScene: SKScene {
    // MARK: - Constants
    private enum Constants {
        static let centerPoint = CGPoint(x: 0.5, y: 0.5)
        static let baseDiamater: CGFloat = 147.0
        static let baseRadius: CGFloat = Constants.baseDiamater / 2
        static let handleDiameter: CGFloat = 58.0
        static let byteSize: CGFloat = 255.0
    }

    // MARK: - Properties
    private let joystick = TLAnalogJoystick(
        withBase: TLAnalogJoystickComponent(diameter: Constants.baseDiamater, image: Image.Controller.gamerPadJoystick),
        handle: TLAnalogJoystickComponent(diameter: Constants.handleDiameter, color: Color.brightRed)
    )

    var positionChanged: CallbackType<CGPoint>?

    // MARK: - Lifecycle
    override func sceneDidLoad() {
        setupJoystick()
        setupScene()
    }
}

// MARK: - Setup
extension JoystickScene {
    private func setupJoystick() {
        joystick.on(.move, handleMoveAndNormalizePosition)
    }

    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .resizeFill
        anchorPoint = Constants.centerPoint
        addChild(joystick)
    }
}

// MARK: - Normalize
extension JoystickScene {
    private func handleMoveAndNormalizePosition(for joystick: TLAnalogJoystick) {
        let position = normalizePoint(joystick.handle.position)
        positionChanged?(position)
    }

    private func normalizePoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: normalizeNumber(point.x), y: normalizeNumber(point.y))
    }

    private func normalizeNumber(_ number: CGFloat) -> CGFloat {
        let ratio = (number + Constants.baseRadius) / Constants.baseDiamater
        let normalized = ratio * Constants.byteSize
        return normalized
    }
}
