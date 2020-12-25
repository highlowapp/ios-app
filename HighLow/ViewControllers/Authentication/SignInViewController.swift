//
//  SignInViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 5/25/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper
import GoogleSignIn
import AuthenticationServices
import PopupDialog

class SignInViewController: UIViewController, UITextFieldDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func saveAppleIDCredentials(params: [String: String]) {
        if let email = params["email"] {
            KeychainWrapper.standard.set(email, forKey: "AppleIDEmail")
        }
        if let firstname = params["firstname"], let lastname = params["lastname"] {
            KeychainWrapper.standard.set(firstname, forKey: "AppleIDGivenName")
            KeychainWrapper.standard.set(lastname, forKey: "AppleIDFamilyName")
        }
        KeychainWrapper.standard.set(true, forKey: "signInWithAppleFailed")
        alert("Something went wrong", "We were unable to sign you in")
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let credential as ASAuthorizationAppleIDCredential:
                
            let userID = credential.user
            
            //Send a request to create a new (or login to an existing) account on High/Low
            var params: [String: String] = [
                "provider_key": userID,
                "provider_name": "apple"
            ]
            
            if let email = credential.email, let fullName = credential.fullName {
                params["email"] = email
                params["firstname"] = fullName.givenName
                params["lastname"] = fullName.familyName
            }
            
            else if (KeychainWrapper.standard.bool(forKey: "signInWithAppleFailed") ?? false) {
                
                if let _ = KeychainWrapper.standard.string(forKey: "AppleIDEmail"), let _ = KeychainWrapper.standard.string(forKey: "AppleIDGivenName"), let _ = KeychainWrapper.standard.string(forKey: "AppleIDFamilyName") {
                    
                } else {
                    let popup = PopupDialog(title: "Something went wrong", message: "Sign in with apple isn't working")
                    popup.addButtons([
                        DefaultButton(title: "How do I fix it?") {
                            let url = URL(string: "https://gethighlow.com/help/appleid.html")
                            
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        },
                        CancelButton(title: "Never Mind", action: nil)
                    ])
                    
                    self.present(popup, animated: true)
                }
                
            }
            
            
            
            
            
            
            AF.request(getHostName() + "/auth/oauth/sign_in", method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
                switch response.result {
                case .success(let result):
                    let json = result as! NSDictionary
                    if (json["error"] as? String) != nil {
                        self.saveAppleIDCredentials(params: params)
                    } else {
                        let access_token = json["access"] as! String
                        let refresh_token = json["refresh"] as! String
                        let uid = json["uid"] as! String
                        
                        let accessSaveSuccessful: Bool = KeychainWrapper.standard.set(access_token, forKey: "access")
                        let refreshSaveSuccessful: Bool = KeychainWrapper.standard.set(refresh_token, forKey: "refresh")
                        let uidSaveSuccessful: Bool = KeychainWrapper.standard.set(uid, forKey: "uid")
                        let userIDSaveSuccessful: Bool = KeychainWrapper.standard.set(userID, forKey: "ASAuthorizationUserID")
                        
                        guard accessSaveSuccessful && refreshSaveSuccessful && uidSaveSuccessful && userIDSaveSuccessful else {
                            alert("Something went wrong", "Please try again")
                            return
                        }
                        
                        switchToMain()
                    }
                case .failure(_):
                    self.saveAppleIDCredentials(params: params)
                    alert("Something went wrong", "Please try again")
                }
                
            }
                    
                
        case let credential as ASPasswordCredential:
            let email = credential.user
            let password = credential.password
            self.signIn(email: email, password: password)
        default:
            break
        }
    }
    
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        let authReq = ASAuthorizationAppleIDProvider().createRequest()
        authReq.requestedScopes = [.fullName, .email]
        let requests = [authReq,
                        ASAuthorizationPasswordProvider().createRequest()]
    
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
    }
    
    //IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Container: UIView!
    @IBOutlet weak var Email: HLTextField!
    @IBOutlet weak var Password: HLTextField!
    @IBOutlet weak var Error: UILabel!
    
    
    
    @IBAction func ForgotPassword(_ sender: Any) {
        let forgotPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        
        self.present(forgotPasswordViewController, animated: true)
    }
    
    
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
        let createAccountViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        
        self.present(createAccountViewController, animated: true)
    }
    
    
    
    
    //Outlet and action for submit button
    @IBOutlet weak var SubmitButton: HLButton!
    @IBAction func Submit(_ sender: Any) {
        let email = Email.textField.text
        let password = Password.textField.text
        
        signIn(email: email ?? "", password: password ?? "")
    }
    
    func signIn(email: String, password: String) {
        
        //Show activity indicator
        SubmitButton.startLoading()
        
        //Sign them in 
        AuthService.shared.signIn(email: email, password: password, onSuccess: { json in
            
            //Hide activity indicator
            self.SubmitButton.stopLoading()
            
            //They're authenticated
            self.switchToTabsScreen()
            
        }, onError: { error in
            self.SubmitButton.stopLoading()
            switch(error) {
            case "incorrect-email-or-password":
                self.Error.text = "Your email or password is incorrect"
            case "user-no-exist":
                self.Error.text = "A user with that email does not exist"
            default:
                self.Error.text = "An error has occurred"
            }
        })
        
    }
    
    
    func switchToTabsScreen() {
        
        switchToMain()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            performExistingAccountSetupFlows()
        }
    }
    
    @IBOutlet weak var gidSignInButton: GIDSignInButton!
    
    
    //Set status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func updateViewColors() {
        self.view.backgroundColor = getColor("White2Black")
        Container.backgroundColor = getColor("White2Black")
        self.scrollView.backgroundColor = getColor("White2Black")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        updateViewColors()
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
                
        gidSignInButton.colorScheme = .dark
        
        //If the user is running iOS 13, add "Sign in with Apple"
        if #available(iOS 13, *) {
            var style = ASAuthorizationAppleIDButton.Style.black
            
            if traitCollection.userInterfaceStyle == .dark {
                style = ASAuthorizationAppleIDButton.Style.white
            }
            
            let signInWithAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: style)
            Container.addSubview(signInWithAppleButton)
            
            signInWithAppleButton.topToBottom(CreateAccountButton, 20).width(230).height(45).centerX(Container)
            
            gidSignInButton.topToBottom(signInWithAppleButton, 20)
            
            signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleId), for: .touchUpInside)
        } else {
            gidSignInButton.topToBottom(CreateAccountButton, 8)
        }
        
        scrollView.contentSize = Container.frame.size
        scrollView.isScrollEnabled = true
        
        //Assign textField delegates
        Email.textField.delegate = self
        Password.textField.delegate = self
        
        
        Password.textField.textContentType = .password
        Email.textField.textContentType = .username
        
        //Secure text entry for password
        Password.isPassword = true
        
        
        //No errors at first!
        Error.text = ""
        
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = Container.frame.size
        scrollView.contentOffset = .zero
    }
    
    @available(iOS 13, *)
    @objc func handleAuthorizationAppleId() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
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
