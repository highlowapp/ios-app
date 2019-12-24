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



//Switch between tab and authentication screens
func switchToMain() {
    let hasPassedInterestsScreen = UserDefaults.standard.bool(forKey: "com.gethighlow.hasPassedInterestsScreen")
    let hasReceivedTutorial = UserDefaults.standard.bool(forKey: "com.gethighlow.hasReceivedTutorial")
    
    if !hasPassedInterestsScreen {
            
        let mainViewController = InterestsPitchViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
    }
    
    else if hasReceivedTutorial {
        
        let storyboard = UIStoryboard(name: "Tabs", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        UIApplication.shared.keyWindow?.rootViewController = mainViewController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
       
    }
    else {
        
        let storyboard = UIStoryboard(name: "Tutorials", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as! TutorialPageViewController
        
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
    
        Alamofire.request("https://api.gethighlow.com/auth/refresh_access", method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
            
            if let result = response.result.value {
                
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
                                        authenticatedRequest(url: "https://api.gethighlow.com/notifications/deregister/" + token, method: .post, parameters: [:], onFinish: { json in
                                            
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
                
            }
            
        }
    
    } else {
        
        callback("invalid-refresh-token")
        
    }
}






//For making authenticated request
func authenticatedRequest(url:String, method: HTTPMethod, parameters:[String:Any], file: UIImage? = nil, onFinish callback: @escaping (_ json: NSDictionary) -> Void, onError fail: @escaping (_ error: String) -> Void){
    
    if let token = KeychainWrapper.standard.string(forKey: "access") {
        
        let headers: [String: String] = [
            "Authorization": "Bearer " + token
        ]
        
        if file != nil {
            
            let imgData = file!.jpegData(compressionQuality: 0.7)!
            
            Alamofire.upload(multipartFormData: { multiPartFormData in
                
                multiPartFormData.append(imgData , withName: "file", fileName: "high-image.JPEG", mimeType: "image/jpeg")
                
                for (key, value) in parameters {
                    multiPartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key )
                }
                
            }, usingThreshold:UInt64.init(), to: url, method: method, headers: headers, encodingCompletion: { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        
                    })
                    
                    upload.responseJSON { response in
                        
                        if let uploadResult = response.result.value {
                            
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
                                            authenticatedRequest(url: url, method: method, parameters: parameters, file: file, onFinish: callback, onError: fail)
                                            
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
                            
                        }
                        
                    }
                    break
                case .failure(let encodingError):
                    fail(encodingError.localizedDescription)
                    break
                }
                
            })
        } else {
            
            //Regular HTTP request, with no file
            Alamofire.request(url, method: method, parameters: parameters as Parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
               
                if let result = response.result.value {
                    
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
                                    authenticatedRequest(url: url, method: method, parameters: parameters, onFinish: callback, onError: fail)
                                    
                                }
                            })
                        }
                        
                        else {
                            fail(error)
                        }
                        
                    } else {
                        
                        callback(json)
                        
                    }
                    
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
func alert(_ title: String, _ message: String) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alertViewController.addAction( UIAlertAction(title: "OK", style: .default, handler: nil) )
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        topController.present(alertViewController, animated: true)
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
        
        authenticatedRequest(url: "https://api.gethighlow.com/user/get/uid", method: .post, parameters: [:], onFinish: { json in
            
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
