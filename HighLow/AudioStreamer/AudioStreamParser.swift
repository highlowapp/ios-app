//
//  AudioStreamParser.swift
//  HighLow
//
//  Created by Caleb Hester on 8/6/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class AudioStreamParser {
    
    var dataFormat: AVAudioFormat?
    var packets = [(Data, AudioStreamPacketDescription?)]()
    
    var frameCount: Int = 0
    var packetCount: Int = 0
    fileprivate var streamId: AudioFileStreamID?
    
    init() throws {
        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        guard AudioFileStreamOpen(context, AudioStreamPropertyChanged, AudioStreamPacketReceived, kAudioFileM4AType, &streamId) == noErr else {
            throw NSError()
        }
        
        
    }
    
    func parse(data: Data) throws {
        let streamId = self.streamId!
        let count = data.count
        _ = try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            let result = AudioFileStreamParseBytes(streamId, UInt32(count), bytes, [])
            guard result == noErr else {
                print(result)
                throw NSError()
            }
        }
    }
    
    
    public var totalPacketCount: AVAudioPacketCount? {
        guard let _ = dataFormat else {
            return nil
        }
        
        return max(AVAudioPacketCount(packetCount), AVAudioPacketCount(packets.count))
    }
    
    var duration: TimeInterval? {
        guard let sampleRate = dataFormat?.sampleRate else {
            return nil
        }
        
        guard let totalFrameCount = totalFrameCount else {
            return nil
        }
        
        return TimeInterval(totalFrameCount) / TimeInterval(sampleRate)
    }
    
    var totalFrameCount: AVAudioFrameCount? {
        guard let framesPerPacket = dataFormat?.streamDescription.pointee.mFramesPerPacket else {
            return nil
        }
        
        guard let totalPacketCount = totalPacketCount else {
            return nil
        }
        
        return AVAudioFrameCount(totalPacketCount) * AVAudioFrameCount(framesPerPacket)
    }
    
    var isParsingComplete: Bool {
        guard let totalPacketCount = totalPacketCount else {
            return false
        }
        
        return packets.count == totalPacketCount
    }
    
    func frameOffset(forTime time: TimeInterval) -> AVAudioFramePosition? {
        guard let _ = dataFormat?.streamDescription.pointee,
            let frameCount = totalFrameCount,
            let duration = duration else {
                return nil
        }
        
        let ratio = time/duration
        return AVAudioFramePosition(Double(frameCount) * ratio)
    }
    
    func packetOffset(forFrame frame: AVAudioFramePosition) -> AVAudioPacketCount? {
        guard let framesPerPacket = dataFormat?.streamDescription.pointee.mFramesPerPacket else {
            return nil
        }
        
        return AVAudioPacketCount(frame) / AVAudioPacketCount(framesPerPacket)
    }
    
    func timeOffset(forFrame frame: AVAudioFrameCount) -> TimeInterval? {
        guard let _ = dataFormat?.streamDescription.pointee,
            let frameCount = totalFrameCount,
            let duration = duration else {
                return nil
        }
        
        return TimeInterval(frame) / TimeInterval(frameCount) * duration
    }
}


func AudioStreamPropertyChanged(_ context: UnsafeMutableRawPointer, _ streamID: AudioFileStreamID, _ propertyID: AudioFileStreamPropertyID, _ flags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
    let parser = Unmanaged<AudioStreamParser>.fromOpaque(context).takeUnretainedValue()
    
    /// Parse the various properties
    switch propertyID {
    case kAudioFileStreamProperty_DataFormat:
        var format = AudioStreamBasicDescription()
        GetPropertyValue(&format, streamID, propertyID)
        parser.dataFormat = AVAudioFormat(streamDescription: &format)
        
    case kAudioFileStreamProperty_AudioDataPacketCount:
        GetPropertyValue(&parser.packetCount, streamID, propertyID)

    default:
        break
    }
}

func AudioStreamPacketReceived(_ context: UnsafeMutableRawPointer, _ byteCount: UInt32, _ packetCount: UInt32, _ data: UnsafeRawPointer, _ packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>?) {
    let parser = Unmanaged<AudioStreamParser>.fromOpaque(context).takeUnretainedValue()
 
    let packetDescriptionsOrNil: UnsafeMutablePointer<AudioStreamPacketDescription>? = packetDescriptions
    let isCompressed = packetDescriptionsOrNil != nil
    
    guard let dataFormat = parser.dataFormat else {
        return
    }
    
    if isCompressed {
        for i in 0 ..< Int(packetCount) {
            guard let packetDescription = packetDescriptions?[i] else {
                return
            }
            let packetStart = Int(packetDescription.mStartOffset)
            let packetSize = Int(packetDescription.mDataByteSize)
            let packetData = Data(bytes: data.advanced(by: packetStart), count: packetSize)
            parser.packets.append((packetData, packetDescription))
        }
    } else {
        let format = dataFormat.streamDescription.pointee
        let bytesPerPacket = Int(format.mBytesPerPacket)
        for i in 0 ..< Int(packetCount) {
            let packetStart = i * bytesPerPacket
            let packetSize = bytesPerPacket
            let packetData = Data(bytes: data.advanced(by: packetStart), count: packetSize)
            parser.packets.append((packetData, nil))
        }
    }
}

func GetPropertyValue<T>(_ value: inout T, _ streamID: AudioFileStreamID, _ propertyID: AudioFileStreamPropertyID) {
    var propSize: UInt32 = 0
    guard AudioFileStreamGetPropertyInfo(streamID, propertyID, &propSize, nil) == noErr else {
        return
    }
    
    guard AudioFileStreamGetProperty(streamID, propertyID, &propSize, &value) == noErr else {
        return
    }
}
