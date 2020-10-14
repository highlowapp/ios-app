//
//  AudioPlayer.swift
//  HighLow
//
//  Created by Caleb Hester on 8/7/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayer: AnyObject {
    var audioPlayerDelegate: AudioPlayerDelegate? { get set }
    var currentTime: TimeInterval { get }
    func resume()
    func pause()
    func stop()
    func getAveragePower() -> CGFloat
}

class LocalAudioPlayer: AVAudioPlayer, AudioPlayer, AVAudioPlayerDelegate {
    weak var audioPlayerDelegate: AudioPlayerDelegate?
    
    override init() {
        super.init()
        self.isMeteringEnabled = true
        self.volume = 1.0
        self.delegate = self
    }
    
    override init(contentsOf url: URL) throws {
        try super.init(contentsOf: url)
        self.isMeteringEnabled = true
        self.volume = 1.0
        self.delegate = self
    }
    
    override init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
        try super.init(contentsOf: url, fileTypeHint: utiString)
        self.isMeteringEnabled = true
        self.volume = 1.0
        self.delegate = self
    }
    
    func resume() {
        self.play()
    }
    
    func getAveragePower() -> CGFloat {
        self.updateMeters()
        return CGFloat(self.averagePower(forChannel: 1))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            audioPlayerDelegate?.audioPlayer(self, didStop: .stopped)
        }
    }
}

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayer(_ audioPlayer: AudioPlayer, didStop state: AudioStreamerState)
}
