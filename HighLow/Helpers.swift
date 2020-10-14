//
//  Helpers.swift
//  HighLow
//
//  Created by Caleb Hester on 5/29/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Alamofire
import Firebase
import UserNotifications
import GoogleSignIn
import PopupDialog

func getRandomQuote() -> Quote? {
    
    return quotes.randomElement()
    
}

struct DynamicColor {
    let lightColor: UIColor
    let darkColor: UIColor
}

struct DynamicImage {
    let lightImage: String
    let darkImage: String
}



let dynamicColors: [String:DynamicColor] = [
    "Pink2White": DynamicColor(lightColor: AppColors.primary, darkColor: .white),
    "White2Pink": DynamicColor(lightColor: .white, darkColor: AppColors.primary),
    "White2Gray": DynamicColor(lightColor: .white, darkColor: UIColor.init(displayP3Red: 0.15, green: 0.15, blue: 0.15, alpha: 1)),
    "White2Black": DynamicColor(lightColor: .white, darkColor: .black),
    "Separator": DynamicColor(lightColor: UIColor.init(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1), darkColor: UIColor.init(displayP3Red: 0.17, green: 0.17, blue: 0.17, alpha: 1)),
    "GrayText": DynamicColor(lightColor: UIColor(displayP3Red: 0.6, green: 0.6, blue: 0.6, alpha: 1), darkColor: UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 1)),
    "BlackText": DynamicColor(lightColor: .black, darkColor: .white),
    "Black2White": DynamicColor(lightColor: .black, darkColor: .white)
]

let dynamicImages: [String: DynamicImage] = [
    "logo": DynamicImage(lightImage: "logo-light-triangles", darkImage: "logo-triangles"),
    "more": DynamicImage(lightImage: "more", darkImage: "more-light")
]

func getImage(_ name: String) -> UIImage? {
    let dynamicImage = dynamicImages[name]
    
    switch themeOverride() {
    case "dark":
        return UIImage(named: dynamicImage!.darkImage)
    case "light":
        return UIImage(named: dynamicImage!.lightImage)
    default:
        return UIImage(named: dynamicImage!.lightImage)
    }
}

extension UIView {
    @objc func updateColors() {}
}


extension UIViewController {
    @objc func updateViewColors() {}
    
    func handleDarkMode() {
        themeSwitch(onDark: {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
            } else {
                // Fallback on earlier versions
            }
        }, onLight: {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
        }, onAuto: {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .unspecified
            } else {
                // Fallback on earlier versions
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChange), name: Notification.Name("com.gethighlow.themeChanged"), object: nil)
    }
    
    @objc func onThemeChange(notification: Notification) {
        if #available(iOS 13, *) {
            let prevTraitCollection = traitCollection
            if notification.userInfo?["theme"] as! String == "dark" {
                overrideUserInterfaceStyle = .dark
            } else if notification.userInfo?["theme"] as! String == "light" {
                overrideUserInterfaceStyle = .light
            } else {
                overrideUserInterfaceStyle = .unspecified
            }
            self.traitCollectionDidChange(prevTraitCollection)
        }
        self.updateViewColors()
        
    }
}


func getColor(_ name: String) -> UIColor? {
    let dynamicColor = dynamicColors[name]
    
    switch themeOverride() {
    case "dark":
        return dynamicColor?.darkColor
    case "light":
        return dynamicColor?.lightColor
    default:
        if #available(iOS 13.0, *) {
            return UIColor { traits -> UIColor in
                if traits.userInterfaceStyle == .dark {
                    return dynamicColor!.darkColor
                }
                return dynamicColor!.lightColor
            }
        }
        return dynamicColor?.lightColor
    }
}

func getHostName() -> String {
    var nsDict: NSDictionary?
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
        nsDict = NSDictionary(contentsOfFile: path)
        
        return nsDict?.object(forKey: "host") as! String
    }
    
    return "https://api.gethighlow.com"
}


func getBibleAPIKey() -> String {
    var nsDict: NSDictionary?
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
        nsDict = NSDictionary(contentsOfFile: path)
        
        return nsDict?.object(forKey: "bibleAPIKey") as! String
    }
    
    return ""
}

func getRevenueCatPublicKey() -> String {
    var nsDict: NSDictionary?
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
        nsDict = NSDictionary(contentsOfFile: path)
        
        return nsDict?.object(forKey: "revenuecatkey") as! String
    }
    else {
        return ""
    }
}


extension Notification.Name {
    static let meditationFocusChanged = Notification.Name("com.gethighlow.meditationFocusUpdated")
    static let endChimeChanged = Notification.Name("com.gethighlow.endChimeChanged")
}


func themeOverride() -> String {
    if let interfaceStyle = UserDefaults.standard.string(forKey: "com.gethighlow.interfaceStyle") {
        if interfaceStyle == "dark" {
            return "dark"
        }
        else if interfaceStyle == "light" {
            return "light"
        }
    }
    return "auto"
}
func themeSwitch(onDark: () -> Void, onLight: () -> Void, onAuto: () -> Void) {
    switch themeOverride() {
    case "dark":
        onDark()
        break
    case "light":
        onLight()
        break
    default:
        onAuto()
    }
}


//Stores primary and secondary colors
struct AppColors {
    static var primary: UIColor = UIColor(hexString: "#FB2A57")
    static var secondary: UIColor = UIColor(hexString: "#FA9C1D")
}

//RGB color functions
func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
}

func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

func niceDate() -> String {
    let currDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: currDate)
}


//Switch between tab and authentication screens
func switchToMain() {
    let hasPassedInterestsScreen = UserDefaults.standard.bool(forKey: "com.gethighlow.hasPassedInterestsScreen")
    
    let hasAgreedToTerms = UserDefaults.standard.bool(forKey: "com.gethighlow.hasAgreedToTerms")
    
    if !hasAgreedToTerms {
        let mainViewController = TermsAndConditionsViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
    } else
    
    if !hasPassedInterestsScreen {
            
        let mainViewController = InterestsPitchViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
    }
    
    else {
        
        let storyboard = UIStoryboard(name: "Tabs", bundle: nil)
        let mainViewController = CustomTabBarController()
        mainViewController.tabBar.barTintColor = getColor("White2Black")
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
       
    }
}

func switchToAuth() {
    let hasReceivedTutorial = UserDefaults.standard.bool(forKey: "com.gethighlow.hasReceivedTutorial")
    if !hasReceivedTutorial {
        return
    }
    
    let authStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
    let signInViewController = authStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
    
    UIApplication.shared.keyWindow?.rootViewController = signInViewController
}



//Attempt to refresh access token
func attemptTokenRefresh(onFinish callback: @escaping (_ result: String) -> Void) {
    
    if let refresh_token = KeychainWrapper.standard.string(forKey: "refresh") {
        let params: [String: String] = [
            "refresh": refresh_token
        ]
    
        AF.request(getHostName() + "/auth/refresh_access", method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success(let result):
                let json = result as! NSDictionary
                
                if let error = json["error"] as? String {
                    if error == "ERROR-INVALID-REFRESH-TOKEN" {
                        
                        //Deregister the user's device for push notifications (accepts outdated tokens)
                        UNUserNotificationCenter.current().getNotificationSettings() { settings in
                            
                            if settings.authorizationStatus == .authorized {
                        
                                InstanceID.instanceID().instanceID { (result, error) in
                                    if error != nil {
                                        return
                                    }
                                
                                    if let result = result {
                                        let token = result.token
                                        authenticatedRequest(url: "/notifications/deregister/" + token, method: .post, parameters: [:], onFinish: { json in
                                            
                                            if json["error"] != nil {
                                                return
                                            }
                                            
                                            
                                            KeychainWrapper.standard.removeObject(forKey: "access")
                                            KeychainWrapper.standard.removeObject(forKey: "refresh")
                                            KeychainWrapper.standard.removeObject(forKey: "uid")
                                            KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                                            GIDSignIn.sharedInstance()?.disconnect()
                                            switchToAuth()
                                            
                                        }, onError: { error in
                                        })
                                        
                                        
                                        
                                    } else {
                                    }
                                }
                            } else {
                                KeychainWrapper.standard.removeObject(forKey: "access")
                                KeychainWrapper.standard.removeObject(forKey: "refresh")
                                KeychainWrapper.standard.removeObject(forKey: "uid")
                                KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                                GIDSignIn.sharedInstance()?.disconnect()
                                switchToAuth()
                            }
                        }
                    }
                    
                    callback("invalid-refresh-token")
                    return
                }
                
                else {
                    
                    if let new_access_token = json["access"] as? String {
                        
                        //Add the new access token to the keychain
                        let accessTokenSaved = KeychainWrapper.standard.set(new_access_token, forKey: "access")
                        
                        if accessTokenSaved {
                            callback(new_access_token)
                            
                        }
                        else {
                            callback("not-saved")
                        }
                        
                    }
                    
                }
            case .failure( _):
                return
            }
            
        }
    
    } else {
        
        callback("invalid-refresh-token")
        
    }
}






//For making authenticated request
func authenticatedRequest(url:String, method: HTTPMethod, parameters:[String:Any], file: UIImage? = nil, onFinish callback: @escaping (_ json: NSDictionary) -> Void, onError fail: @escaping (_ error: String) -> Void){
    let oldUrl = url
    let url = getHostName() + url
    
    if let token = KeychainWrapper.standard.string(forKey: "access") {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        if file != nil {
            
            let imgData = file!.jpegData(compressionQuality: 0.7)!
            AF.upload(multipartFormData: { multiPartFormData in
                
                multiPartFormData.append(imgData , withName: "file", fileName: "high-image.JPEG", mimeType: "image/jpeg")
                
                for (key, value) in parameters {
                    if value is String {
                        multiPartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key )
                    }
                    else if value is Bool {
                        multiPartFormData.append((value as! Bool).description.data(using: String.Encoding.utf8)!, withName: key )
                    }
                }
                
            }, to: url, headers: headers).uploadProgress(queue: .main, closure: { progress in
                
                }).responseJSON { response in
                    
                    switch response.result {
                    case .success(let uploadResult):
                        let json = uploadResult as! NSDictionary
                        
                        if let error = json["error"] as? String {
                            
                            if error == "ERROR-INVALID-TOKEN" {
                                //Remove token and ask for a refresh
                                KeychainWrapper.standard.removeObject(forKey: "access")
                                
                                //Refresh token
                                attemptTokenRefresh(onFinish: {result in
                                    if result == "invalid-refresh-token" {
                                        fail("invalid-refresh-token")
                                        switchToAuth()
                                    } else if result == "not-saved" {
                                        fail("refresh-token-not-saved")
                                        switchToAuth()
                                    } else {
                                        
                                        //Try again recursively
                                        authenticatedRequest(url: oldUrl, method: method, parameters: parameters, file: file, onFinish: callback, onError: fail)
                                        
                                    }
                                })
                                
                                
                            }
                            
                            else {
                                fail(error)
                            }
                            
                        } else {
                            
                            //The JSON is clean, and we can callback with the data
                            callback(json)
                            
                        }
                    case .failure(_):
                        return
                    }
                    
                }
        
        } else {
            
            //Support headers
            var finalParams: [String: Any] = [
                "supports_html": true
            ]
            
            finalParams.merge(parameters, uniquingKeysWith: { (current, _) in current })
            
            //Regular HTTP request, with no file
            AF.request(url, method: method, parameters: finalParams, encoding: (method == .get ? URLEncoding.queryString:URLEncoding.httpBody), headers: headers).responseJSON { response in
               
                switch response.result {
                case .success(let result):
                    let json = result as! NSDictionary
                    
                    if let error = json["error"] as? String {
                        
                        //If it's an invalid token error, try to refresh the token
                        if error == "ERROR-INVALID-TOKEN" {
                            
                            //Remove token
                            KeychainWrapper.standard.removeObject(forKey: "access")
                            
                            //Refresh token
                            attemptTokenRefresh(onFinish: { result in
                                if result == "invalid-refresh-token" {
                                    fail("invalid-refresh-token")
                                    switchToAuth()
                                } else if result == "not-saved" {
                                    fail("refresh-token-not-saved")
                                    switchToAuth()
                                } else {
                                    
                                    //Try again recursively
                                    authenticatedRequest(url: oldUrl, method: method, parameters: parameters, onFinish: callback, onError: fail)
                                    
                                }
                            })
                        }
                        
                        else {
                            fail(error)
                        }
                        
                    } else {
                        callback(json)
                        
                    }
                case .failure(let error):
                    fail(error.errorDescription!)
                }
             }
        }
 
        
    } else {
        
        switchToAuth()
        
        fail("no-token")
        return
        
    }
    
}


//Display alert
func alert(_ title: String = "An error occurred", _ message: String = "Please try again", handler: (() -> Void)? = nil) {
    
    let popup = PopupDialog(title: title, message: message)
    
    let button = CancelButton(title: "OK", action: handler)
    
    popup.addButton(button)
        
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        topController.present(popup, animated: true)
    }
}




//Debugging
extension UIView {
    func showBorder(_ color: UIColor, _ width: CGFloat?) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width ?? 1
    }
}




//Getting current date as date string with format yyyy-MM-dd
func getTodayDateStr() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateStr = dateFormatter.string(from: date)
    
    return dateStr
}


func dateStrToRegularDate(dateStr: String) -> String {
    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter1.date(from: dateStr)!
    let dateFormatter2 = DateFormatter()
    dateFormatter2.dateStyle = .medium
    dateFormatter2.timeStyle = .none
    
    return dateFormatter2.string(from: date)
}




func getUid(callback: @escaping (_ uid: String) -> Void) {
    
    if let uid = KeychainWrapper.standard.string(forKey: "uid") {
        callback(uid)
    } else {
        
        authenticatedRequest(url: "/user/get/uid", method: .post, parameters: [:], onFinish: { json in
            
            if json["error"] != nil {
                alert("An error occurred", "Try closing the app and opening it again")
            }
            
            else if let uid = json["uid"] as? String {
                KeychainWrapper.standard.set(uid, forKey: "uid")
                callback(uid)
            }
            else {
                alert("An error occurred", "Try closing the app and opening it again")
            }
            
        }, onError: { error in
            
            alert("An error occurred", "Try closing the app and opening it again")
            
        })
        
    }
    
}




func openURL(_ url: String) {
    guard let url = URL(string: url) else {return}
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}


func getPaywall() -> SwiftPaywall {
    let paywall = SwiftPaywall(termsOfServiceUrlString: "https://gethighlow.com/termsofservice", privacyPolicyUrlString: "https://gethighlow.com/privacy", allowRestore: true, backgroundColor: .white, textColor: AppColors.primary, productSelectedColor: AppColors.primary, productDeselectedColor: AppColors.secondary)
    paywall.titleLabel.text = "Get Full Access"
    paywall.subtitleLabel.text = "With High/Low Premium, you get unlimited diary blocks, unlimited time for audio diaries and meditation sessions, and access to exclusive content! "
    return paywall
}


