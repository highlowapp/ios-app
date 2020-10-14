//
//  MeditationViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/3/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class MeditationViewController: UIViewController {
    
    var focus: [String: Any]?
    
    let clockLabel: UILabel = UILabel()
    let focusLabel: UILabel = UILabel()
    let endButton = HLButton()
    
    var timer: Timer?
    
    var meditationLength: TimeInterval = 60
    var endChime: EndChime = .chime1
    
    var currentLength: TimeInterval = 0
    
    weak var delegate: MeditationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = GradientUIView()
        gradient.startColor = AppColors.primary.withAlphaComponent(0.39)
        gradient.endColor = AppColors.secondary.withAlphaComponent(0.39)
        gradient.angle = -45
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(gradient)
        
        gradient.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        var cancel: UIButton = UIButton()
        if #available(iOS 13, *) {
            cancel = UIButton(type: .close)
        } else {
            cancel.setTitle("Cancel", for: .normal)
            cancel.setTitleColor(.white, for: .normal)
        }
        cancel.addTarget(self, action: #selector(cancelMeditation), for: .touchUpInside)
        self.view.addSubview(cancel)
        cancel.tintColor = .white
        cancel.eqLeading(self.view, 20).eqTop(self.view.safeAreaLayoutGuide, 20)
        

        endButton.colorStyle = "white"
        endButton.title = "End Session"
        
        clockLabel.textAlignment = .center
        clockLabel.textColor = .white
        clockLabel.font = .systemFont(ofSize: 30)
        
        clockLabel.text = meditationLength.stringFromTimeInterval()
        
        focusLabel.font = .preferredFont(forTextStyle: .body)
        focusLabel.textColor = .white
        focusLabel.numberOfLines = 0
        
        let container = UIView()
        
        self.view.addSubview(container)
        
        container.addSubviews([clockLabel, focusLabel, endButton])
        
        container.centerX(self.view).centerY(self.view).eqWidth(self.view, 0, 0.7)
        
        clockLabel.eqTop(container).eqLeading(container).eqTrailing(container)
        focusLabel.topToBottom(clockLabel, 20).eqLeading(container).eqTrailing(container)
        endButton.topToBottom(focusLabel, 20).centerX(container).width(240).height(50)
        
        container.eqBottom(endButton)
        
        
        if let focus = focus, let focusText = focus["focus"] as? String {
            focusLabel.text = focusText
        }
        
        endButton.addTarget(self, action: #selector(endSession), for: .touchUpInside)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.currentLength >= self.meditationLength {
                timer.invalidate()
                self.didFinishMeditationSession()
            } else {
                self.currentLength += 1
                let diffInterval: TimeInterval = self.meditationLength - self.currentLength
                self.clockLabel.text = diffInterval.stringFromTimeInterval()
            }
        })
    }
    
    func didFinishMeditationSession() {
        //Play selected end chime, update UI to say "You're done" and have a "Finish" button
        playEndChime(endChime)
        
        clockLabel.text = "You're Done!"
        endButton.title = "Finish Session"
    }
    
    @objc func cancelMeditation() {
        timer?.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func endSession() {
        timer?.invalidate()
        endButton.startLoading()
        ActivityService.shared.createActivity(type: .meditation, data: [
            "length": currentLength,
            "title": UUID().uuidString
        ], onSuccess: { activity in
            self.endButton.stopLoading()
            self.dismiss(animated: true, completion: { [unowned self] in
                self.delegate?.meditationViewControllerDidEndMeditation()
            })
        }, onError: { error in
            self.endButton.stopLoading()
            alert("An error occurred", "Please try again")
        })
    }
    
}

protocol MeditationViewControllerDelegate: AnyObject {
    func meditationViewControllerDidEndMeditation()
}
