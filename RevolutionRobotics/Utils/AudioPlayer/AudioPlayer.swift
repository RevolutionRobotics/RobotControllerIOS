//
//  AudioPlayer.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 06. 13..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioPlayer {
    // MARK: - Constants
    private enum Constants {
        static let mp3Extension = "mp3"
    }

    // MARK: - Properties
    private var player: AVAudioPlayer?

    // MARK: - Play
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: Constants.mp3Extension) else {
            print("Couldn't find \(name) in boundle")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
