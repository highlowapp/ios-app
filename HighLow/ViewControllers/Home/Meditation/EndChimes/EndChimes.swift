//
//  EndChimes.swift
//  HighLow
//
//  Created by Caleb Hester on 9/4/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?

enum EndChime: String {
    case chime1 = "End Chime 1"
    case chime2 = "End Chime 2"
    case chime3 = "End Chime 3"
}

func playEndChime(_ endChime: EndChime) {
    guard let url = Bundle.main.url(forResource: endChime.rawValue, withExtension: "mp3") else { return }

    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        guard let player = player else { return }
        player.volume = 1
        player.play()

    } catch let error {
        printer(error.localizedDescription, .error)
    }
}
