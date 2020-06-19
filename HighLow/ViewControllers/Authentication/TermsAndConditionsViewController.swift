//
//  TermsAndConditionsViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 1/20/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import GoogleSignIn

class TermsAndConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let cont = UIView()
        self.view.addSubview(cont)
        cont.centerX(self.view).centerY(self.view).eqWidth(self.view)
        
        let agreement = UILabel()
        agreement.text = "In order to continue, you must accept our privacy policy and terms of service"
        agreement.numberOfLines = 0
        agreement.textAlignment = .center
        agreement.font = .systemFont(ofSize: 20)
        
        let tosButton = HLButton(frame: CGRect(x: 0, y: 0, width: 240, height: 40))
        tosButton.colorStyle = "white"
        tosButton.title = "Terms of Service"
        tosButton.gradientOn = false
        
        let privacyPolicyButton = HLButton(frame: CGRect(x: 0, y: 0, width: 240, height: 40))
        privacyPolicyButton.colorStyle = "white"
        privacyPolicyButton.title = "Privacy Policy"
        privacyPolicyButton.gradientOn = false
        
        let controls = UIStackView()
        controls.axis = .horizontal
        controls.distribution = .fillProportionally
        
        let agree = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        agree.colorStyle = "pink"
        agree.title = "Accept"
        
        let disagree = HLButton(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        disagree.colorStyle = "white"
        disagree.title = "Decline"
        disagree.gradientOn = false
        
        cont.addSubview(agreement)
        cont.addSubview(tosButton)
        cont.addSubview(privacyPolicyButton)
        cont.addSubview(controls)
        
        tosButton.backgroundColor = .none
        privacyPolicyButton.backgroundColor = .none
        
        tosButton.addTarget(self, action: #selector(openTermsOfService), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        
        controls.addArrangedSubview(agree)
        controls.setCustomSpacing(20, after: agree)
        controls.addArrangedSubview(disagree)
        
        agreement.centerX(cont).eqTop(cont).eqWidth(cont, 0.0, 0.8)
        tosButton.topToBottom(agreement, 10).centerX(cont)
        privacyPolicyButton.topToBottom(tosButton, 10).centerX(cont)
        controls.centerX(cont).topToBottom(privacyPolicyButton, 40).width(240).height(40)
        
        cont.eqBottom(controls)
        
        
        agree.addTarget(self, action: #selector(acceptTheConditions), for: .touchUpInside)
        disagree.addTarget(self, action: #selector(declineTheConditions), for: .touchUpInside)
        
        UserDefaults.standard.removeObject(forKey: "com.gethighlow.DailyNotif")
        UserDefaults.standard.removeObject(forKey: "com.gethighlow.DailyNotifTime")
    }
    
    @objc func acceptTheConditions() {
        UserDefaults.standard.set(true, forKey: "com.gethighlow.hasAgreedToTerms")
        switchToMain()
    }
    
    @objc func declineTheConditions() {
        KeychainWrapper.standard.removeObject(forKey: "access")
        KeychainWrapper.standard.removeObject(forKey: "refresh")
        KeychainWrapper.standard.removeObject(forKey: "uid")
        KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
        GIDSignIn.sharedInstance()?.disconnect()
        switchToAuth()
    }
    
    func openURL(_ url: String) {
        guard let url = URL(string: url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func openPrivacyPolicy() {
        openURL("https://gethighlow.com/privacy")
    }
    @objc func openTermsOfService() {
        openURL("https://gethighlow.com/eula")
    }
    
}
