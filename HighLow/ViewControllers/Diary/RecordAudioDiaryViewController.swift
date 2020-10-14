//
//  RecordAudioDiaryViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/31/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import AVFoundation
import Purchases

class RecordAudioDiaryViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, ProgressLoaderViewDelegate, AudioPlayerDelegate, AudioPremiumWarningViewDelegate {
    
    let recordingFileName: String = "recording.flac"
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatFLAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    var audioPlayer: AudioPlayer?
    let audioStreamer: AudioStreamer = AudioStreamer()
    var timer: Timer?
    
    var hasRecorded: Bool = false
    var isLoading: Bool = false {
        didSet {
            loadingView.isHidden = !isLoading
        }
    }
    var isShowingWarning: Bool = false {
        didSet {
            audioVisualizer.isHidden = isShowingWarning
            audioPremiumWarning.isHidden = !isShowingWarning
        }
    }
    var hasPremium: Bool = false
    
    var audioTranscription: String = niceDate()
    
    let audioVisualizer = AudioVisualizerView()
    let audioPremiumWarning = AudioPremiumWarningView()
    let clock = UILabel()
    let recordButton: RecordButton = RecordButton()
    let playButton: PlayButton = PlayButton()
    let doneButton: Pill = Pill()
    let loadingView: ProgressLoaderView = ProgressLoaderView()
    let shareButton = Pill()
    
    var startDate: Date = Date()
    let dateFormatter: DateComponentsFormatter = DateComponentsFormatter()
    
    var activity: ActivityResource? {
        didSet {
            shareButton.isHidden = activity == nil
        }
    }
    
    var transcriptionFinished: Bool = true
    var isCanceling: Bool = false
    var audioFile: AudioFile?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        audioVisualizer.backgroundColor = rgb(240, 240, 240)
        audioVisualizer.setMeters(peak: -160, avg: -160)
        
        audioVisualizer.isHidden = isShowingWarning
        audioPremiumWarning.isHidden = !isShowingWarning
        
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Done", for: .normal)
        cancelButton.setTitleColor(AppColors.primary, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        shareButton.clipsToBounds = true
        shareButton.backgroundColor = AppColors.secondary
        shareButton.isHidden = activity == nil
        
        
        let shareTapper = UITapGestureRecognizer(target: self, action: #selector(editSharingPolicy))
        shareButton.addGestureRecognizer(shareTapper)
        
        let label = UILabel()
        label.textColor = .white
        label.text = "Share"
        label.textAlignment = .center
        
        shareButton.addSubview(label)
        label.eqTop(shareButton, 5).centerX(shareButton)
        shareButton.eqLeading(label, -10).eqTrailing(label, 10).eqBottom(label, 5)
        
        self.addSubviews([cancelButton, shareButton])
        
        cancelButton.eqTop(self.view, 20).eqLeading(self.view, 20)
        shareButton.centerY(cancelButton).eqTrailing(self.view, -20)
        
        let audioIcon = UIImageView(image: UIImage(named: "AudioDiarySmallIcon"))
        
        
        let header = UILabel()
        
        header.text = "Audio Entry"
        header.numberOfLines = 0
        header.textColor = .black
        header.textAlignment = .center
        header.font = .preferredFont(forTextStyle: .headline)
        
        self.addSubviews([audioIcon, header])
        
        audioIcon.topToBottom(shareButton).centerX(self.view)
        header.topToBottom(audioIcon, 10).eqLeading(self.view).eqTrailing(self.view)
        
        let container = UIView()
        container.addSubviews([audioVisualizer, clock, audioPremiumWarning])
        self.addSubviews([container, recordButton, playButton, doneButton, loadingView])
        
        audioVisualizer.eqLeading(container).eqTrailing(container).eqTop(container).eqHeight(self.view, 0, 0.33)
        clock.eqLeading(container).eqTrailing(container).topToBottom(audioPremiumWarning, 20)
        container.eqBottom(clock)
        
        audioPremiumWarning.eqLeading(container).eqTrailing(container).eqTop(container)
        
        clock.text = "0:00"
        clock.numberOfLines = 1
        clock.textAlignment = .center
        clock.font = .systemFont(ofSize: 50)
        
        
        doneButton.showBorder(rgb(69, 246, 76), 2)
        let doneLabel = UILabel()
        doneLabel.text = "Save"
        doneLabel.textColor = rgb(69, 246, 76)
        doneLabel.textAlignment = .center
        doneButton.addSubview(doneLabel)
        doneLabel.eqLeading(doneButton, 10).eqTrailing(doneButton, -10).centerY(doneButton)
        doneButton.eqBottom(doneLabel, 20).aspectRatioFromWidth(1).width(70)
        doneButton.isHidden = true
        
        let tapper = UITapGestureRecognizer()
        tapper.addTarget(self, action: #selector(saveEntry(creating:)))
        doneButton.addGestureRecognizer(tapper)
        
        loadingView.eqTop(self.view).eqBottom(self.view).eqLeading(self.view).eqTrailing(self.view)
        loadingView.isHidden = !isLoading
        
        //header.centerX(self.view).eqTop(self.view, 30).eqWidth(self.view, 0.8)
        container.centerY(self.view).eqLeading(self.view).eqTrailing(self.view)
        recordButton.centerX(self.view).eqBottom(self.view, -30).width(70)
        
        
        recordButton.addTarget(self, action: #selector(toggleRecord), for: .touchUpInside)
        recordButton.showBorder(.red, 1)
        
        playButton.centerY(recordButton).trailingToLeading(recordButton, -30).width(50)
        playButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        if activity == nil {
            playButton.disable()
        }
        
        doneButton.centerY(recordButton).leadingToTrailing(recordButton, 30)
        
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.includesApproximationPhrase = false
        dateFormatter.includesTimeRemainingPhrase = false
        
        loadingView.delegate = self
        
        updatePremiumStatus()
        
        audioPremiumWarning.delegate = self
    }
    
    func updatePremiumStatus() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["Premium"]?.isActive == true {
                self.hasPremium = true
            } else {
                self.hasPremium = false
            }
        }
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleRecord() {
        if !recordButton.isDisabled {
            switch recordButton.recordingState {
            case .paused, .stopped:
                setupAudioRecordSession()
                break
            case .recording:
                recordButton.stopRecording()
                stopRecording()
                break
            }
        }
    }
    
    @objc func togglePlayback() {
        if !playButton.isDisabled {
            playButton.togglePlaying()
            
            if playButton.isPlaying {
                setupAudioPlaybackSession()
            } else {
                stopPlaying()
            }
        }
    }
    
    @objc func editSharingPolicy() {
        let sharingPolicyViewController = SharingPolicyViewController()
        sharingPolicyViewController.activity = activity
        self.present(sharingPolicyViewController, animated: true)
    }
    
    @objc func saveEntry(creating: Bool = true) {
        /*
        Saving will be done in a few steps:
        1. Getting the audio transcription
        2. Uploading the audio file to the server
        3. Creating an entry in the database for the audio diary
         */
        self.isLoading = true
        transcriptionFinished = false
        loadingView.setTitle("Transcribing audio...")
        loadingView.setProgress(0)
        loadingView.allowsSkip = true
        let audioUrl = getDocumentsDirectory().appendingPathComponent(recordingFileName)
        audioFile = AudioFile(url: audioUrl)
        isCanceling = false
        audioFile?.getTranscription { transcription, inProgress in
            if inProgress {
                self.loadingView.setProgress(0.165)
            } else {
                self.transcriptionFinished = true
                
                if !self.isCanceling {
                    self.loadingView.setProgress(0.33)
                    self.audioTranscription = transcription
                    self.loadingView.allowsSkip = false
                    self.uploadAudio(self.audioFile!) { url in
                        if self.activity == nil {
                            self.createEntry(url: url)
                        } else {
                            self.updateEntry(url: url)
                        }
                    }
                } else {
                    self.isCanceling = false
                }
            }
        }
        
        
    }
    
    func createEntry(url: String) {
        self.loadingView.setTitle("Saving Entry...")
        
        let data: [String: Any] = [
            "audio_file": url,
            "transcription": self.audioTranscription,
            "title": self.audioTranscription
        ]
        
        ActivityService.shared.createActivity(type: .audio, data: data as NSDictionary, onSuccess: { activity in
            self.loadingView.setProgress(1)
            self.loadingView.setTitle("Success!")
            self.activity = activity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.transcriptionFinished = false
            }
        }, onError: { error in
            self.isLoading = false
            self.transcriptionFinished = false
            alert("An error occurred", "Please try again")
        })
    }
    
    func updateEntry(url: String) {
        self.loadingView.setTitle("Saving Entry...")
        
        let data: [String: Any] = [
            "audio_file": url,
            "transcription": self.audioTranscription,
            "title": self.audioTranscription
        ]
        
        activity?.update(data: data as NSDictionary, onSuccess: {
            self.loadingView.setProgress(1)
            self.loadingView.setTitle("Success!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.transcriptionFinished = false
            }
        }, onError: { error in
            self.isLoading = false
            self.transcriptionFinished = false
            alert("An error occurred", "Please try again")
        })
    }
    
    func uploadAudio(_ audioFile: AudioFile, _ callback: @escaping (_ url: String) -> Void) {
        self.loadingView.setTitle("Uploading Audio...")
        ActivityService.shared.uploadAudio(audioFile: audioFile, onSuccess: { url in
            callback(url)
        }, onError: { error in
            self.isLoading = false
            self.transcriptionFinished = false
            alert("An error occurred", "Please try again")
        }, onProgressUpdate: { progress in
            self.loadingView.setProgress(Float(progress.fractionCompleted)/3 + 0.33)
        })
    }
    
    func didSkip() {
        if !transcriptionFinished {
            isCanceling = true
            self.loadingView.setProgress(0.33)
            self.audioTranscription = niceDate()
            loadingView.allowsSkip = false
            self.uploadAudio(audioFile!) { url in
                if self.activity == nil {
                    self.createEntry(url: url)
                } else {
                    self.updateEntry(url: url)
                }
            }
        }
    }
}


extension RecordAudioDiaryViewController {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        /*
        playButton.togglePlaying()
        timer?.invalidate()
        recordButton.enable()
        doneButton.isHidden = false
         */
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didStop state: AudioStreamerState) {
        playButton.togglePlaying()
        timer?.invalidate()
        recordButton.enable()
        doneButton.isHidden = false
        
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["Premium"]?.isActive == true {
                self.hasPremium = true
                self.isShowingWarning = true
            } else {
                self.hasPremium = false
                self.isShowingWarning = false
            }
        }
    }
    
    func getFileURLForPlaying() -> URL {
        var url: URL? = nil
        if activity != nil && activity?.type == "audio" {
            if let audioUrl = activity?.data?["audio_file"] as? String {
                url = URL(string: audioUrl)
            }
        }
        
        else if url == nil {
            url = getDocumentsDirectory().appendingPathComponent(recordingFileName)
        }
        
        return url!
    }
    
    func startPlaying() {
        
            let url = getFileURLForPlaying()
            do {
                if url.isFileURL {
                    self.audioPlayer = try LocalAudioPlayer(contentsOf: url)
                } else {
                    self.audioPlayer = audioStreamer
                    audioStreamer.url = url
                }
                self.audioPlayer?.audioPlayerDelegate = self
                
                self.recordButton.disable()
                self.doneButton.isHidden = true
                
                self.audioPlayer?.resume()
                timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    let avg = 160 * pow(1.09, CGFloat(self.audioPlayer!.getAveragePower())+5) - 160
                    self.audioVisualizer.setMeters(peak: 0, avg: avg)
                    let t = self.audioPlayer?.currentTime
                    self.clock.text = t?.stringFromTimeInterval()
                }
            } catch {
                print(error.localizedDescription)
            }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        timer?.invalidate()
        
        recordButton.enable()
        doneButton.isHidden = false
    }
    
    func setupAudioRecordSession() {
        if recordButton.recordingState == .stopped {
            audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                audioSession.requestRecordPermission { [unowned self] allowed in
                    if allowed {
                        self.startRecording()
                    } else {
                        
                    }
                }
            } catch {
                
            }
        }
        else if recordButton.recordingState == .paused {
            resumeRecording()
        }
        
        recordButton.startRecording()
    }
    
    func setupAudioPlaybackSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            isShowingWarning = false
            audioStreamer.play()
            self.startPlaying()
        } catch {
            
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordingFileName)
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            self.startDate = Date()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                guard let audioRecorder = self.audioRecorder else {
                    self.timer?.invalidate()
                    return
                }
                
                audioRecorder.updateMeters()
                let peak = CGFloat(audioRecorder.peakPower(forChannel: 1))
                let avg = 160 * pow(1.09, CGFloat(audioRecorder.averagePower(forChannel: 1))+5) - 160
                self.audioVisualizer.setMeters(peak: peak, avg: avg)
                self.updateTimeCode(withTimeInterval: audioRecorder.currentTime)
            }
            
        } catch {
            printer(error, .error)
        }
    }
    
    func pauseRecording() {
        audioRecorder.pause()
        playButton.enable()
        
        recordButton.pauseRecording()
    }
    
    func resumeRecording() {
        recordButton.resumeRecording()
        audioRecorder.record()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            self.audioRecorder.updateMeters()
            let peak = CGFloat(self.audioRecorder.peakPower(forChannel: 1))
            let avg = 160 * pow(1.09, CGFloat(self.audioRecorder.averagePower(forChannel: 1))+5) - 160
            self.audioVisualizer.setMeters(peak: peak, avg: avg)
            self.updateTimeCode(withTimeInterval: self.audioRecorder.currentTime)
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        timer?.invalidate()
        audioRecorder = nil
        
        playButton.enable()
        doneButton.isHidden = false
        recordButton.stopRecording()
    }
    
    func updateTimeCode(withTimeInterval timeCode: TimeInterval) {
        self.clock.text = timeCode.stringFromTimeInterval()
        
        if timeCode >= 45 {
            updatePremiumStatus()
            self.isShowingWarning = !hasPremium
            let remaining = max(0, ceil(60 - timeCode))
            self.audioPremiumWarning.updateTimeCode(withTimeInterval: remaining)
        } else {
            self.isShowingWarning = false
        }
        
        if self.isShowingWarning && timeCode >= 60 {
            stopRecording()
            let paywall = getPaywall()
            self.present(paywall, animated: true, completion: nil)
        }
    }
    
    func audioPremiumWarningWillPresentPaywall() {
        pauseRecording()
        
        let paywall = getPaywall()
        self.present(paywall, animated: true, completion: nil)
    }
}


extension TimeInterval{

    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)

        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d",minutes,seconds)

    }
}
