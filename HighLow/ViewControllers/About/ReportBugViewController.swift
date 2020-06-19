//
//  ReportBugViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/28/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class ReportBugViewController: UIViewController {
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var SubjectInput: HLTextField!
    
    @IBOutlet weak var MessageInput: UITextView!
    
    @IBOutlet weak var SubmitButton: HLButton!
    
    
    @IBAction func submitReport(_ sender: Any) {
        SubmitButton.startLoading()
        
        let params: [String: String] = [
            "title": SubjectInput.textField.text ?? "Untitled Report",
            "message": MessageInput.text
        ]
        
        authenticatedRequest(url: "/bug_reports/submit", method: .post, parameters: params, onFinish: { json in
            self.SubmitButton.stopLoading()
            if json["status"] == nil {
                alert("An error occurred", "Please try again")
            } else {
                alert("Your report has been submitted", "We will address it as soon as we can")
            }
        }, onError: { error in
            alert("An error occurred", "Please try again")
            self.SubmitButton.stopLoading()
        })
    }
    
    override func updateViewColors() {
        self.view.backgroundColor = getColor("White2Black")
        MessageInput.backgroundColor = getColor("Separator")
        MessageInput.textColor = getColor("BlackText")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        self.navigationController?.navigationBar.barStyle = .black
        
        updateViewColors()
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        MessageInput.keyboardDismissMode = .onDrag
        scrollView.keyboardDismissMode = .interactive
            
        MessageInput.text = "Describe the bug..."
        
        SubjectInput.backgroundColor = .white

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
