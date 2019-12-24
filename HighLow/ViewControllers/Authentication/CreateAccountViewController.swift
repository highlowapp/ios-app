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
    
    
    @IBOutlet weak var SubmitButton: HLButton!
    @IBAction func SignUp(_ sender: Any) {
        
        //Parameters
        let firstName = FirstName.textField.text ?? ""
        let lastName = LastName.textField.text ?? ""
        let email = Email.textField.text ?? ""
        let password = Password.textField.text ?? ""
        let confirmPassword = ConfirmPassword.textField.text ?? ""
        
        let parameters: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "email": email,
            "password": password,
            "confirmpassword": confirmPassword
        ]
        
        //Show activity indicator
        SubmitButton.startLoading()
        
        
        //Make the request
        Alamofire.request("https://api.gethighlow.com/auth/sign_up", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).validate().responseJSON { response in
            
            //Hide the activity indicator
            self.SubmitButton.stopLoading()
            
            if let result = response.result.value {
                
                //Convert to JSON
                let JSON = result as! NSDictionary
                
                //Check for errors
                let errorExists = JSON["error"] != nil
                
                if errorExists {
                    
                    let error = JSON["error"] as! String
                    
                    //Display an error message
                    self.Error.text  = self.errorMessages[error] as? String
                    
                }
                
                //Otherwise...
                else {
                    
                    //Get the token and store in the keychain
                    let access = JSON["access"] as! String
                    let refresh = JSON["refresh"] as! String
                    let uid = JSON["uid"] as! String
 
                    let accessSaveSuccessful: Bool = KeychainWrapper.standard.set(access, forKey: "access")
                    let refreshSaveSuccessful: Bool = KeychainWrapper.standard.set(refresh, forKey: "refresh")
                    let uidSaveSuccessful: Bool = KeychainWrapper.standard.set(uid, forKey: "uid")
                    
                    guard accessSaveSuccessful == true && refreshSaveSuccessful == true && uidSaveSuccessful == true else {
                        
                        //Display an alert
                        let alert = UIAlertController(title: "Error", message: "Something went wrong when signing you in. Please try again.", preferredStyle: .alert)
                        
                    alert.addAction(UIAlertAction( title: "OK", style: .default, handler: nil ))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                        
                    }
                    
                    
                    //If the token saving was successful, go to the tabs screen!
                    switchToMain()
                    
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        
        
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
