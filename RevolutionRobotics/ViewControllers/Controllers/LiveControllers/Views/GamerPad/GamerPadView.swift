//
//  GamerPadView.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SpriteKit

final class GamerPadView: UIView, PlayablePadView {
    // MARK: - Outlets
    @IBOutlet private weak var joystickContainer: SKView!
    @IBOutlet private var buttons: [PadButton]!

    // MARK: - Playable
    var xAxisPositionChanged: CallbackType<CGFloat>?
    var yAxisPositionChanged: CallbackType<CGFloat>?
    var buttonTapped: CallbackType<PressedPadButton>?

    func configure(programs: [ProgramDataModel?]) {
        programs.enumerated().forEach { [weak self] in
            let (index, program) = $0
            guard let unwrappedProgram = program else { return }
            self?.connectButtonHandling(at: index, program: unwrappedProgram, to: buttons[index])
        }
    }
}

// MARK: View lifecycle
extension GamerPadView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupJoystickScene(in: joystickContainer)
    }
}
