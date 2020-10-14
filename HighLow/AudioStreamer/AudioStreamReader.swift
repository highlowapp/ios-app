//
//  AudioStreamReader.swift
//  HighLow
//
//  Created by Caleb Hester on 8/6/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import AVFoundation

let ReaderReachedEndOfDataError: OSStatus = 932332581
let ReaderNotEnoughDataError: OSStatus = 932332582
let ReaderMissingSourceFormatError: OSStatus = 932332583

class AudioStreamReader {
    var currentPacket: AVAudioPacketCount = 0
    let audioStreamParser: AudioStreamParser
    let readFormat: AVAudioFormat
    
    var converter: AudioConverterRef? = nil
    private let queue = DispatchQueue(label: "com.gethighlow.audioStream")
    
    required init(audioStreamParser: AudioStreamParser, readFormat: AVAudioFormat) throws {
        self.audioStreamParser = audioStreamParser
        
        guard let dataFormat = audioStreamParser.dataFormat else {
            throw AudioStreamReaderError.parserMissingDataFormat
        }
        
        let sourceFormat = dataFormat.streamDescription
        let commonFormat = readFormat.streamDescription
        let result = AudioConverterNew(sourceFormat, commonFormat, &converter)
        guard result == noErr else {
            throw AudioStreamReaderError.unableToCreateConverter(result)
        }
        
        self.readFormat = readFormat
    }
    
    deinit {
        guard AudioConverterDispose(converter!) == noErr else {
            return
        }
    }
    
    func read(_ frames: AVAudioFrameCount) throws -> AVAudioPCMBuffer {
        let framesPerPacket = readFormat.streamDescription.pointee.mFramesPerPacket
        var packets = frames / framesPerPacket
        guard let buffer = AVAudioPCMBuffer(pcmFormat: readFormat, frameCapacity: frames) else {
            throw AudioStreamReaderError.failedToCreatePCMBuffer
        }
        
        buffer.frameLength = frames
        
        try queue.sync {
            let context =  unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            let status = AudioConverterFillComplexBuffer(converter!, ReaderConverterCallback, context, &packets, buffer.mutableAudioBufferList, nil)
            guard status == noErr else {
                switch status {
                case ReaderMissingSourceFormatError:
                    throw AudioStreamReaderError.parserMissingDataFormat
                case ReaderReachedEndOfDataError:
                    throw AudioStreamReaderError.reachedEndOfFile
                case ReaderNotEnoughDataError:
                    throw AudioStreamReaderError.notEnoughData
                default:
                    throw AudioStreamReaderError.converterFailed(status)
                }
            }
        }
        
        return buffer
    }
    
    func seek(_ packet: AVAudioPacketCount) {
        queue.sync {
            currentPacket = packet
        }
    }
}


func ReaderConverterCallback(_ converter: AudioConverterRef,  _ packetCount: UnsafeMutablePointer<UInt32>, _ ioData: UnsafeMutablePointer<AudioBufferList>, _ outPacketDescriptions: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?, _ context: UnsafeMutableRawPointer?) -> OSStatus {
    let audioStreamReader = Unmanaged<AudioStreamReader>.fromOpaque(context!).takeUnretainedValue()
    
    guard let sourceFormat = audioStreamReader.audioStreamParser.dataFormat else {
        return ReaderMissingSourceFormatError
    }
    
    let packetIndex = Int(audioStreamReader.currentPacket)
    let packets = audioStreamReader.audioStreamParser.packets
    let isEndOfData = packetIndex >= packets.count
    if isEndOfData {
        if audioStreamReader.audioStreamParser.isParsingComplete {
            packetCount.pointee = 0
            return ReaderReachedEndOfDataError
        } else {
            return ReaderNotEnoughDataError
        }
    }
    
    let packet = packets[packetIndex]
    var data = packet.0
    let dataCount = data.count
    ioData.pointee.mNumberBuffers = 1
    ioData.pointee.mBuffers.mData = UnsafeMutableRawPointer.allocate(byteCount: dataCount, alignment: 0)
    _ = data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in
        memcpy((ioData.pointee.mBuffers.mData?.assumingMemoryBound(to: UInt8.self))!, bytes, dataCount)
    }
    ioData.pointee.mBuffers.mDataByteSize = UInt32(dataCount)
    
    let sourceFormatDescription = sourceFormat.streamDescription.pointee
    if sourceFormatDescription.mFormatID != kAudioFormatLinearPCM {
        if outPacketDescriptions?.pointee == nil {
            outPacketDescriptions?.pointee = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: 1)
        }
        outPacketDescriptions?.pointee?.pointee.mDataByteSize = UInt32(dataCount)
        outPacketDescriptions?.pointee?.pointee.mStartOffset = 0
        outPacketDescriptions?.pointee?.pointee.mVariableFramesInPacket = 0
    }
    
    packetCount.pointee = 1
    audioStreamReader.currentPacket = audioStreamReader.currentPacket + 1
    
    return noErr;
}


public enum AudioStreamReaderError: LocalizedError {
    case cannotLockQueue
    case converterFailed(OSStatus)
    case failedToCreateDestinationFormat
    case failedToCreatePCMBuffer
    case notEnoughData
    case parserMissingDataFormat
    case reachedEndOfFile
    case unableToCreateConverter(OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .cannotLockQueue:
            return "Failed to lock queue"
        case .converterFailed(let status):
            return localizedDescriptionFromConverterError(status)
        case .failedToCreateDestinationFormat:
            return "Failed to create a destination (processing) format"
        case .failedToCreatePCMBuffer:
            return "Failed to create PCM buffer for reading data"
        case .notEnoughData:
            return "Not enough data for read-conversion operation"
        case .parserMissingDataFormat:
            return "Parser is missing a valid data format"
        case .reachedEndOfFile:
            return "Reached the end of the file"
        case .unableToCreateConverter(let status):
            return localizedDescriptionFromConverterError(status)
        }
    }
    
    func localizedDescriptionFromConverterError(_ status: OSStatus) -> String {
        switch status {
        case kAudioConverterErr_FormatNotSupported:
            return "Format not supported"
        case kAudioConverterErr_OperationNotSupported:
            return "Operation not supported"
        case kAudioConverterErr_PropertyNotSupported:
            return "Property not supported"
        case kAudioConverterErr_InvalidInputSize:
            return "Invalid input size"
        case kAudioConverterErr_InvalidOutputSize:
            return "Invalid output size"
        case kAudioConverterErr_BadPropertySizeError:
            return "Bad property size error"
        case kAudioConverterErr_RequiresPacketDescriptionsError:
            return "Requires packet descriptions"
        case kAudioConverterErr_InputSampleRateOutOfRange:
            return "Input sample rate out of range"
        case kAudioConverterErr_OutputSampleRateOutOfRange:
            return "Output sample rate out of range"
#if os(iOS)
        case kAudioConverterErr_HardwareInUse:
            return "Hardware is in use"
        case kAudioConverterErr_NoHardwarePermission:
            return "No hardware permission"
#endif
        default:
            return "Unspecified error"
        }
    }
}
