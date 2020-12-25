//
//  StartMeditationSessionViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 8/18/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class StartMeditationSessionViewController: UIViewController, MeditationViewControllerDelegate {
    func meditationViewControllerDidEndMeditation() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    let circularSlider: MTCircularSlider = MTCircularSlider()
    let scrollView: TouchyScrollview = TouchyScrollview()
    let timeLabel: UILabel = UILabel()
    let minLabel: UILabel = UILabel()
    
    let meditationOptions = [
        MeditationOptionView().setImage("MeditationFocus").setTitle("Meditation Focus"),
        /* MeditationOptionView().setImage("BackgroundMusic").setTitle("Background Music"),*/ // To be implemented later
        MeditationOptionView().setImage("EndChime").setTitle("End Chime")
    ]
    
    var meditationFocus: [String: Any] = [:]
    var endChime: EndChime = .chime1

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        let gradient = GradientUIView()
        gradient.startColor = AppColors.primary.withAlphaComponent(0.74)
        gradient.endColor = AppColors.secondary.withAlphaComponent(0.74)
        gradient.angle = -45
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        self.view.backgroundColor = .white
        self.view.addSubviews([gradient, doneButton])
        
        doneButton.eqLeading(self.view.safeAreaLayoutGuide, 20).eqTop(self.view.safeAreaLayoutGuide).width(50).height(40)
        gradient.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        
        let sliderAttrs = [
            Attributes.minTrackTint(.white),
            Attributes.maxTrackTint(rgb(220, 220, 220)),
            Attributes.trackWidth(7),
            Attributes.trackShadowRadius(0),
            Attributes.trackShadowDepth(0),
            Attributes.trackMinAngle(0),
            Attributes.maxWinds(CGFloat.infinity),
            Attributes.hasThumb(true),
            Attributes.thumbTint(.white),
            Attributes.thumbRadius(20),
            Attributes.touchPadding(20)
        ]
        
        circularSlider.applyAttributes(sliderAttrs)
        circularSlider.addTarget(self, action: #selector(circularSliderChangedValue), for: .valueChanged)
        circularSlider.value = 0
        
        gradient.addSubview(scrollView)
        
        scrollView.delaysContentTouches = false
        scrollView.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view.safeAreaLayoutGuide).eqBottom(self.view)
        
        scrollView.addSubview(circularSlider)
            
        circularSlider.eqTop(scrollView, 20)
        
        circularSlider.centerX(self.view).eqWidth(self.view, 0, 0.8).aspectRatioFromWidth(1)
        
        let labelContainer = UIView()
        
        circularSlider.addSubview(labelContainer)
        
        timeLabel.text = "0"
        timeLabel.textColor = .white
        timeLabel.font = .systemFont(ofSize: 45)
        timeLabel.textAlignment = .center
        minLabel.text = "minutes"
        minLabel.textColor = .white
        minLabel.font = .systemFont(ofSize: 25)
        minLabel.textAlignment = .center
        
        labelContainer.addSubviews([timeLabel, minLabel])
        
        timeLabel.eqTop(labelContainer).eqLeading(labelContainer).eqTrailing(labelContainer)
        minLabel.topToBottom(timeLabel, 10).eqLeading(labelContainer).eqTrailing(labelContainer)
        
        labelContainer.eqLeading(circularSlider).eqTrailing(circularSlider).centerY(circularSlider).eqBottom(minLabel)
        
        labelContainer.isUserInteractionEnabled = false
        timeLabel.isUserInteractionEnabled = false
        minLabel.isUserInteractionEnabled = false
        
        let unsureLabel = UIButton()
        unsureLabel.setTitle("  Is meditation right for me?", for: .normal)
        unsureLabel.setTitleColor(.white, for: .normal)
        unsureLabel.addTarget(self, action: #selector(unsure), for: .touchUpInside)
        unsureLabel.titleLabel?.font = .boldSystemFont(ofSize: 20)
        unsureLabel.setImage(UIImage(named: "Help"), for: .normal)
        
        scrollView.addSubview(unsureLabel)
        
        unsureLabel.eqWidth(scrollView).centerX(scrollView).topToBottom(circularSlider, 10)
        
        
        scrollView.addSubviews(meditationOptions)
        
        var previous: MeditationOptionView? = nil
        for option in meditationOptions {
            if previous == nil {
                option.topToBottom(unsureLabel, 30).eqLeading(self.view).eqTrailing(self.view)
            } else {
                option.topToBottom(previous!, 20).eqLeading(self.view).eqTrailing(self.view)
            }
            
            previous = option
        }
        
        let startButton = HLButton()
        startButton.colorStyle = "white"
        startButton.title = "Start Meditation"
        startButton.addTarget(self, action: #selector(startMeditation), for: .touchUpInside)
        scrollView.addSubview(startButton)
        
        if let previous = previous {
            startButton.topToBottom(previous, 20).centerX(self.view).width(250).height(50)
        }
        
        startButton.eqBottom(scrollView, -30)
        
        if meditationOptions.count > 0 {
            meditationOptions[0].setTarget(self, action: #selector(setMeditationFocus))
            NotificationCenter.default.addObserver(self, selector: #selector(onFocusChange(notification:)), name: .meditationFocusChanged, object: nil)
        }
        if meditationOptions.count > 1 {
            meditationOptions[1].setTarget(self, action: #selector(setEndChime))
            NotificationCenter.default.addObserver(self, selector: #selector(onEndChimeChange(notification:)), name: .endChimeChanged, object: nil)
        }
    }
    
    @objc func onFocusChange(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: Any], let focus = userInfo["focus"], meditationOptions.count > 0 {
            let meditationFocusOption = meditationOptions[0]
            if let reference = userInfo["reference"] {
                meditationFocusOption.setValue(reference as? String ?? "None")
            } else {
                meditationFocusOption.setValue(focus as? String ?? "None")
            }
            
            meditationFocus = userInfo
        }
    }
    
    @objc func onEndChimeChange(notification: NSNotification) {
        if let userInfo = notification.userInfo as? [String: Any], let chime = userInfo["chime"] as? EndChime, let title = userInfo["title"] as? String, meditationOptions.count > 1 {
            let endChimeOption = meditationOptions[1]
            endChimeOption.setValue(title)
            
            endChime = chime
        }
    }
    
    @objc func circularSliderChangedValue() {
        let value = circularSlider.getThumbAngle() - CGFloat.pi
        /*
         2PI radians = 60 minutes
         
         valMinutes = value (radians) / 1 * (60 minutes / 2PI radians)
         */
        let valMinutes = round( value * 60 / (2 * CGFloat.pi) )
        timeLabel.text = String(Int(valMinutes))
        
    }

    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func startMeditation() {
        let meditationViewController = MeditationViewController()
        meditationViewController.focus = meditationFocus
        meditationViewController.modalPresentationStyle = .fullScreen
        meditationViewController.delegate = self
        
        let sliderValue = circularSlider.getThumbAngle() - CGFloat.pi
        let valMinutes = round( sliderValue * 60 / (2 * CGFloat.pi) )
        let valSeconds = valMinutes * 60
        
        if valMinutes < 1 {
            alert("Select a Length of Time", "Use the circular slider above to set how long you'll be meditating for!")
            return
        }
        
        meditationViewController.meditationLength = TimeInterval(valSeconds)
        meditationViewController.endChime = endChime
        
        self.present(meditationViewController, animated: true)
    }
    
    @objc func unsure() {
        openURL("https://gethighlow.com/help/meditation.html")
    }
    
    @objc func setEndChime() {
        let endChimeChooser = ChooseEndChimeViewController()
        self.present(endChimeChooser, animated: true)
    }
    
    @objc func setMeditationFocus() {
        let meditationFocusChooser = ChooseMeditationFocusViewController()
        self.present(meditationFocusChooser, animated: true, completion: nil)
    }
    
}

class TouchyScrollview: UIScrollView {
    
}
