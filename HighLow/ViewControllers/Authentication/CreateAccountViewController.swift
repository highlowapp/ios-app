//
//  CreateAccountViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 5/30/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import PopupDialog

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    let errorMessages: [String: Any] = [
        "empty-first-name": "Please enter a first name",
        "empty-last-name": "Please enter a last name",
        "empty-email": "Please enter an email",
        "email-already-taken": "A user with that email already exists",
        "invalid-email": "The email given was invalid",
        "password-too-short": "Your password must be at least 6 characters",
        "passwords-no-match": "Passwords don't match"
    ]
    
    
    //IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var FirstName: HLTextField!
    @IBOutlet weak var LastName: HLTextField!
    @IBOutlet weak var Email: HLTextField!
    @IBOutlet weak var Password: HLTextField!
    @IBOutlet weak var ConfirmPassword: HLTextField!
    @IBOutlet weak var Error: UILabel!
    
    @IBAction func PrivacyPolicy(_ sender: Any) {
        openURL("https://gethighlow.com/privacy")
    }
    
    @IBAction func TermsOfService(_ sender: Any) {
        openURL("https://gethighlow.com/eula")
    }
    
    func openURL(_ url: String) {
        guard let url = URL(string: url) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    @IBOutlet weak var SubmitButton: HLButton!
    @IBAction func SignUp(_ sender: Any) {
        
        //Parameters
        let firstName = FirstName.textField.text ?? ""
        let lastName = LastName.textField.text ?? ""
        let email = Email.textField.text ?? ""
        let password = Password.textField.text ?? ""
        let confirmPassword = ConfirmPassword.textField.text ?? ""
        
        //Show activity indicator
        SubmitButton.startLoading()
        
        AuthService.shared.signUp(firstname: firstName, lastname: lastName, email: email, password: password, confirmPassword: confirmPassword, onSuccess: { json in
            self.SubmitButton.stopLoading()
            
            switchToMain()
        }, onError: { error in
            self.SubmitButton.stopLoading()
            self.Error.text = self.errorMessages[error] as? String
        })
        
    }
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //Set TextField delegates
        FirstName.textField.delegate = self
        LastName.textField.delegate = self
        Email.textField.delegate = self
        Password.textField.delegate = self
        ConfirmPassword.textField.delegate = self
        
        //Secure text entry
        Password.isPassword = true
        ConfirmPassword.isPassword = true
        
        if #available(iOS 12.0, *) {
            Password.textField.textContentType = .newPassword
            ConfirmPassword.textField.textContentType = .newPassword
        } else {
            Password.textField.textContentType = .password
            ConfirmPassword.textField.textContentType = .password
        }
        
        Email.textField.textContentType = .username
        
        
        
        SubmitButton.gradientOn = false
        
        //No errors at first!
        Error.text = ""
        
    }
    
    
    
    //Set status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    
    
    
    //Scroll to textfields automatically
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
    }
}
