//
//  AudioStreamer.swift
//  HighLow
//
//  Created by Caleb Hester on 8/6/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import AVFoundation
import Accelerate

class AudioStreamer: AudioStreamDownloadManagerDelegate, AudioPlayer {
    var audioPlayerDelegate: AudioPlayerDelegate?
        
    private let kMinLevel: Float = 0.000_000_01
    
    func resume() {
        play()
    }
    
    var averagePower: CGFloat = 0
    
    func getAveragePower() -> CGFloat {
        return averagePower
    }
    
    var readBufferSize: AVAudioFrameCount {
        return 8192
    }
    
    var readFormat: AVAudioFormat {
        return AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: false)!
    }
        
    var currentTime: TimeInterval {
        guard let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
                return TimeInterval.zero
        }
        let currentTime = TimeInterval(playerTime.sampleTime) / playerTime.sampleRate
        
        return currentTime + currentTimeOffset
    }
    
    var currentTimeOffset: TimeInterval = 0
    var isFileSchedulingComplete = false
    
    weak var delegate: AudioStreamerDelegate?
    
    var duration: TimeInterval?
    lazy var downloadManager: AudioStreamDownloadManager = {
        let downloadManager = AudioStreamDownloadManager()
        downloadManager.delegate = self
        return downloadManager
    }()
    
    var audioParser: AudioStreamParser?
    var audioReader: AudioStreamReader?
    
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    
    var state: AudioStreamerState = .stopped {
        didSet {
            delegate?.audioStreamer(self, changedState: state)
        }
    }
    
    var url: URL? {
        didSet {
            reset()
            
            if let url = url {
                downloadManager.url = url
                downloadManager.startDownload()
            }
        }
    }
    
    var volume: Float {
        get {
            return audioEngine.mainMixerNode.outputVolume
        }
        
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
    }
    
    init() {
        setupAudioEngine()
    }
    
    func getPowerFromAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        var powerLevels: [CGFloat] = []
        let channelCount = Int(buffer.format.channelCount)
        let length = vDSP_Length(buffer.frameLength)
        
        if let floatData = buffer.floatChannelData {
            for channel in 0..<channelCount {
                powerLevels.append(calculatePower(data: floatData[channel], strideFrames: buffer.stride, length: length))
            }
        } else if let int16Data = buffer.int16ChannelData {
            for channel in 0..<channelCount {
                // convert data from int16 to float values before calculating power values
                var floatChannelData: [Float] = Array(repeating: Float(0.0), count: Int(buffer.frameLength))
                vDSP_vflt16(int16Data[channel], buffer.stride, &floatChannelData, buffer.stride, length)
                var scalar = Float(INT16_MAX)
                vDSP_vsdiv(floatChannelData, buffer.stride, &scalar, &floatChannelData, buffer.stride, length)

                powerLevels.append(calculatePower(data: floatChannelData, strideFrames: buffer.stride, length: length))
            }
        } else if let int32Data = buffer.int32ChannelData {
            for channel in 0..<channelCount {
                // convert data from int32 to float values before calculating power values
                var floatChannelData: [Float] = Array(repeating: Float(0.0), count: Int(buffer.frameLength))
                vDSP_vflt32(int32Data[channel], buffer.stride, &floatChannelData, buffer.stride, length)
                var scalar = Float(INT32_MAX)
                vDSP_vsdiv(floatChannelData, buffer.stride, &scalar, &floatChannelData, buffer.stride, length)

                powerLevels.append(calculatePower(data: floatChannelData, strideFrames: buffer.stride, length: length))
            }
        }
        
        if powerLevels.count > 0 {
            averagePower = powerLevels[0]
        }
    }
    
    func calculatePower(data: UnsafePointer<Float>, strideFrames: Int, length: vDSP_Length) -> CGFloat {
        var rms: Float = 0.0
        vDSP_rmsqv(data, strideFrames, &rms, length)
        if rms < kMinLevel {
            rms = kMinLevel
        }
        
        return CGFloat(20.0 * log10(rms))
    }
    
    func setupAudioEngine() {
        attachNodes()
        connectNodes()
        
        audioEngine.mainMixerNode.installTap(onBus: .zero, bufferSize: 1024, format: audioEngine.mainMixerNode.outputFormat(forBus: .zero)) { audioBuffer, audioTime in
            self.getPowerFromAudioBuffer(audioBuffer)
        }
        
        audioEngine.prepare()
        
        let interval = 1 / (readFormat.sampleRate / Double(readBufferSize))
        Timer.scheduledTimer(withTimeInterval: interval / 2, repeats: true) { [weak self] _ in
            self?.scheduleNextBuffer()
            self?.handleTimeUpdate()
            self?.notifyTimeUpdated()
        }
    }
    
    func attachNodes() {
        audioEngine.attach(playerNode)
    }
    
    func connectNodes() {
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: readFormat)
    }
    
    func handleTimeUpdate() {
        guard let duration = duration else {
            return
        }
        
        if currentTime >= duration {
            try? seek(to: 0)
            audioPlayerDelegate?.audioPlayer(self, didStop: self.state)
            stop()
        }
    }
    
    func notifyTimeUpdated() {
        guard audioEngine.isRunning, playerNode.isPlaying else {
            return
        }
        
        delegate?.audioStreamer(self, updatedCurrentTime: currentTime)
    }
    
    func reset() {
        stop()
        
        duration = nil
        audioReader = nil
        isFileSchedulingComplete = false
        state = .stopped
        
        do {
            audioParser = try AudioStreamParser()
        } catch {
            printer("Failed to instantiate parser", .error)
        }
    }
    
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, completedWithError error: Error?) {
        if let error = error, let url = downloadManager.url {
            delegate?.audioStreamer(self, failedDownloadWithError: error, forURL: url)
        }
    }
    
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, changedState state: AudioStreamDownloadManagerState) {
        
    }
    
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, didReceiveData data: Data, fractionReceived: Float) {
        guard let audioParser = audioParser else {
            return
        }
        
        do {
            try audioParser.parse(data: data)
        } catch {
            printer("Failed to parse audio stream: \(error)", .error)
        }
        
        if audioReader == nil, let _ = audioParser.dataFormat {
            do {
                audioReader = try AudioStreamReader(audioStreamParser: audioParser, readFormat: readFormat)
            } catch {
                printer("Failed to instantiate reader", .error)
            }
        }
        
        DispatchQueue.main.async {
            [weak self] in
            self?.notifyDownloadProgress(fractionReceived)
            self?.handleDurationUpdate()
        }
    }
    
    func notifyDownloadProgress(_ fractionReceived: Float) {
        guard let url = url else {
            return
        }
        
        delegate?.audioStreamer(self, updatedDownloadProgress: fractionReceived, forURL: url)
    }
    
    func handleDurationUpdate() {
        if let newDuration = audioParser?.duration {
            var shouldUpdate = false
            if duration == nil {
                shouldUpdate = true
            } else if let oldDuration = duration, oldDuration < newDuration {
                shouldUpdate = true
            }
            
            if shouldUpdate {
                self.duration = newDuration
                notifyDurationUpdate(newDuration)
            }
        }
    }
    
    func notifyDurationUpdate(_ duration: TimeInterval) {
        guard let _ = url else {
            return
        }
        
        delegate?.audioStreamer(self, updatedDuration: duration)
    }
    
    func scheduleNextBuffer() {
        guard let audioReader = audioReader else {
            return
        }
        guard !isFileSchedulingComplete else {
            return
        }
        
        do {
            let nextScheduledBuffer = try audioReader.read(readBufferSize)
            playerNode.scheduleBuffer(nextScheduledBuffer)
        }  catch AudioStreamReaderError.reachedEndOfFile {
            isFileSchedulingComplete = true
        } catch {
            printer("Failed to read", .error)
        }
    }
    
    
    func play() {
        guard !playerNode.isPlaying else {
            return
        }
        
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                printer("Failed to start AudioEngine", .error)
                return
            }
        }
        
        playerNode.play()
        
        state = .playing
    }
    
    func pause() {
        guard playerNode.isPlaying else {
            return
        }
        
        playerNode.pause()
        audioEngine.pause()
        
        state = .paused
    }
    
    func stop() {
        downloadManager.stopDownload()
        playerNode.stop()
        audioEngine.stop()
        
        state = .stopped
    }
    
    func seek(to time: TimeInterval) throws {
        guard let audioParser = audioParser, let audioReader = audioReader else {
            return
        }
        
        guard let frameOffset = audioParser.frameOffset(forTime: time),
            let packetOffset = audioParser.packetOffset(forFrame: frameOffset) else {
                return
        }
        
        currentTimeOffset = time
        isFileSchedulingComplete = false
        
        let isPlaying = playerNode.isPlaying
        
        playerNode.stop()
        
        audioReader.seek(packetOffset)
        
        if isPlaying {
            playerNode.play()
        }
        
        delegate?.audioStreamer(self, updatedCurrentTime: time)
    }
}

enum AudioStreamerState {
    case stopped
    case paused
    case playing
}

protocol AudioStreamerDelegate: AnyObject {
    func audioStreamer(_ audioStreamer: AudioStreamer, failedDownloadWithError error: Error, forURL url: URL)
    func audioStreamer(_ audioStreamer: AudioStreamer, updatedDownloadProgress progress: Float, forURL url: URL)
    func audioStreamer(_ audioStreamer: AudioStreamer, changedState state: AudioStreamerState)
    func audioStreamer(_ audioStreamer: AudioStreamer, updatedDuration duration: TimeInterval)
    func audioStreamer(_ audioStreamer: AudioStreamer, updatedCurrentTime currentTime: TimeInterval)
}
