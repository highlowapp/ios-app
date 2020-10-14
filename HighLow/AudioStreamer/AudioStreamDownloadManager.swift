//
//  AudioStreamDownloadManager.swift
//  HighLow
//
//  Created by Caleb Hester on 8/6/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

class AudioStreamDownloadManager: NSObject, URLSessionDataDelegate {
    var fractionReceived: Float {
        get {
            guard bytesExpected != 0 else {
                return 0.0
            }
            return Float(bytesReceived) / Float(bytesExpected)
        }
    }
    
    private var bytesReceived: Int = 0
    private var bytesExpected: Int = 0
    
    private var currentState: AudioStreamDownloadManagerState = .stopped
    
    private var task: URLSessionDataTask?
    fileprivate lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    var url: URL? {
        didSet {
            if currentState == .inProgress {
                stopDownload()
            }
            
            if let url = url {
                currentState = .stopped
                bytesExpected = 0
                bytesReceived = 0
                task = urlSession.dataTask(with: url)
            } else {
                task = nil
            }
        }
    }
    
    weak var delegate: AudioStreamDownloadManagerDelegate?
    
    func startDownload() {
        guard let task = task else {
            return
        }
        
        switch currentState {
        case .inProgress, .finished:
            return
        default:
            currentState = .inProgress
            task.resume()
            delegate?.downloadManager(self, changedState: currentState)
        }
    }
    
    func pauseDownload() {
        guard let task = task else {
            return
        }
        
        if currentState == .inProgress {
            currentState = .paused
            task.suspend()
            delegate?.downloadManager(self, changedState: currentState)
        }
    }
    
    func stopDownload() {
        guard let task = task else {
            return
        }
        
        if currentState == .inProgress {
            currentState = .stopped
            task.cancel()
            delegate?.downloadManager(self, changedState: currentState)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        bytesExpected = Int(response.expectedContentLength)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived += data.count
        delegate?.downloadManager(self, didReceiveData: data, fractionReceived: fractionReceived)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        currentState = .finished
        delegate?.downloadManager(self, completedWithError: error)
    }
}

enum AudioStreamDownloadManagerState {
    case finished
    case inProgress
    case paused
    case stopped
}

protocol AudioStreamDownloadManagerDelegate: AnyObject {
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, changedState state: AudioStreamDownloadManagerState)
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, completedWithError error: Error?)
    func downloadManager(_ downloadManager: AudioStreamDownloadManager, didReceiveData data: Data, fractionReceived: Float)
}
