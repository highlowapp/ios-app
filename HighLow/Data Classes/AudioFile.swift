//
//  AudioFile.swift
//  HighLow
//
//  Created by Caleb Hester on 8/4/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import Speech

class AudioFile: Uploadable {
    
    var url: URL!
    var data: Data?
    
    init(url: URL) {
        self.url = url
        do {
        self.data = try Data(contentsOf: url)
        } catch {
            printer(error, .error)
            self.data = Data()
        }
    }
    
    func getTranscription(callback: @escaping (_ transcription: String, _ inProgress: Bool) -> Void) {
        requestTranscribePermissions { success in
            if success {
                self.transcribe { transcription, inProgress in
                    callback(transcription, inProgress)
                }
            } else {
                callback(niceDate(), false)
            }
        }
    }
    
    func transcribe(_ callback: @escaping (_ transcription: String, _ inProgress: Bool) -> Void) {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: self.url)
        recognizer?.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                callback(niceDate(), false)
                return
            }
            
            if result.isFinal {
                callback(result.bestTranscription.formattedString, false)
            } else {
                callback(niceDate(), true)
            }
        }
        
    
    }
    
    func requestTranscribePermissions(callback: @escaping (_ success: Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    callback(true)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func getData() -> Data {
        return self.data!
    }
    
    func getName() -> String {
        return "audio.flac"
    }
    
    func getMIMEType() -> String {
        return "audio/flac"
    }
}
