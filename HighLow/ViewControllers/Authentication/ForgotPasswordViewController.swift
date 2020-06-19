//
//  ForgotPasswordViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/4/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    let errorMessages: [String: String] = [
        "user-no-exist": "Whoops! That user doesn't exist!"
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated:true)
    }
    @IBOutlet weak var Email: HLTextField!
    @IBOutlet weak var Message: UILabel!
    @IBOutlet weak var SubmitButton: HLButton!
    @IBAction func SendConfirmationEmail(_ sender: Any) {
        
        let email = Email.textField.text ?? ""
        
        let parameters: [String: Any] = [
            "email": email
        ]
        
        SubmitButton.startLoading()
        
        AF.request(getHostName() + "/auth/forgot_password", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).validate().responseJSON { response in
            
            self.SubmitButton.stopLoading()
            
            switch response.result {
            case .success(let result):
                //Convert to JSON
                let JSON = result as! NSDictionary
                
                //Check for errors
                let errorExists = JSON["error"] as! String != ""
                
                if errorExists {
                    
                    let error = JSON["error"] as! String
                    
                    self.Message.text = self.errorMessages[error]
                    
                }
                    
                    //Otherwise...
                else {
                    
                    self.Message.text = "Success! You should be receiving an email shortly."
                    
                }
            case .failure( _):
                return
                
                
            }
            
        }
        
    }
    
    //Set status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        //Set textfield delegate
        Email.textField.delegate = self
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
