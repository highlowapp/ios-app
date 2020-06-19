//
//  EditCommentViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/16/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class EditCommentViewController: UIViewController, UITextViewDelegate {
    
    var commentid: String?
    var message: String?
    
    weak var delegate: EditCommentViewControllerDelegate?
    
    var textView: UITextView = UITextView()
    var textViewHasBeenEdited: Bool = false
    let errorLabel: UILabel = UILabel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        self.view.backgroundColor = .white
        
        themeSwitch(onDark: {
            self.view.backgroundColor = .black
            self.textView.backgroundColor = .none
        }, onLight: {
        }, onAuto: {
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                self.view.backgroundColor = .black
                self.textView.backgroundColor = .none
            }
        })
        

        //Filler view, to protect content on devices such as iPhone X with a notch
        let fillerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        
        self.view.addSubview(fillerView)
        
        //fillerView constraints
        fillerView.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).bottomToTop(self.view.safeAreaLayoutGuide)
        
        fillerView.backgroundColor = AppColors.primary
        
        
        
        //Controls
        let controls = UIView()
        
        controls.backgroundColor = AppColors.primary
        
        let controlsStack = UIStackView()
        
        controls.addSubview(controlsStack)
        
        controlsStack.centerX(controls).centerY(controls).eqWidth(controls).eqHeight(controls)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        
        
        controlsStack.axis = .horizontal
        controlsStack.distribution = .fillEqually
        controlsStack.addArrangedSubview(cancelButton)
        controlsStack.addArrangedSubview(doneButton)
        
        self.view.addSubview(controls)
        
        controls.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view.safeAreaLayoutGuide).eqWidth(self.view).height(50)
        
        
        //Error label
        errorLabel.textColor = UIColor.red
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.text = "2048 chars left"
        
        self.view.addSubview(errorLabel)
        
        errorLabel.topToBottom(controls, 10).eqLeading(self.view).eqTrailing(self.view)
        
        //textView
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.keyboardDismissMode = .onDrag
        textView.delegate = self
        textView.textColor = getColor("BlackText")
        
        if let msg = message {
            textView.text = msg
        }
        
        
        self.view.addSubview(textView)
        
        textView.topToBottom(errorLabel, 20).eqLeading(self.view, 20).eqTrailing(self.view, -20).eqBottom(self.view.safeAreaLayoutGuide, -20)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        errorLabel.text = String(2048 - textView.text.count) + " chars left"
        scrollTextViewToBottom(textView: textView)
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = textView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 40
        textView.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        textView.contentInset = contentInset
        
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        return numberOfChars < 2048
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func done() {
        
        let loader = HLLoaderView()
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(loader)
        
        loader.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        loader.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        loader.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        loader.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        CommentViewCell.editComment(loader: loader, commentid: commentid ?? "", message: textView.text) {
            
            self.delegate?.editCommentViewControllerDidFinishEditing(sender: self)
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }

}


protocol EditCommentViewControllerDelegate: AnyObject {
    func editCommentViewControllerDidFinishEditing(sender: EditCommentViewController)
}
