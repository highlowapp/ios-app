//
//  AppDelegate.swift
//  HighLow
//
//  Created by Caleb Hester on 3/10/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper
import GoogleSignIn
import Alamofire
import AuthenticationServices
import Firebase
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, MessagingDelegate {
    
    let reachability = try! Reachability()
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let params: [String: Any] = [
            "platform": 0,
            "device_id": fcmToken
        ]
        
        UIApplication.shared.registerForRemoteNotifications()
        
        authenticatedRequest(url: "https://api.gethighlow.com/notifications/register", method: .post, parameters: params, onFinish: { json in
        }, onError: { error in
        })
    }
    
    func notReachable(_ reachability: Reachability) {
        let alert = UIAlertController(title: "Internet Error", message: "Can't connect to the internet. Please try again later.", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
    
    //For Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            //Check other authentication methods
            checkAppleAuth()
            switchToAuth()
            return
          } else {
          }
          return
        }

        let provider_key = user.authentication.idToken
        let provider_name = "google";
        let firstname = user.profile.givenName
        let lastname = user.profile.familyName
        let email = user.profile.email
        let profileimage = user.profile.imageURL(withDimension: 256 )
        
        var params: [String: String] = [:]
        
        //I'm sure there's a better way of doing this...
        if provider_key != nil {
            params["provider_key"] = provider_key
        }
        
        params["provider_name"] = provider_name
        
        if firstname != nil {
            params["firstname"] = firstname
        }
        if lastname != nil {
            params["lastname"] = lastname
        }
        if email != nil {
            params["email"] = email
        }
        if profileimage != nil {
            params["profileimage"] = profileimage?.absoluteString
        }
        
        Alamofire.request("https://api.gethighlow.com/auth/oauth/sign_in", method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseJSON { response in
            
            if let result = response.result.value {
                
                let json = result as! NSDictionary
                if (json["error"] as? String) != nil {
                    alert("Something went wrong", "We were unable to sign you in")
                } else {
                    
                    let access_token = json["access"] as! String
                    let refresh_token = json["refresh"] as! String
                    let uid = json["uid"] as! String
                    
                    let accessSaveSuccessful: Bool = KeychainWrapper.standard.set(access_token, forKey: "access")
                    let refreshSaveSuccessful: Bool = KeychainWrapper.standard.set(refresh_token, forKey: "refresh")
                    let uidSaveSuccessful: Bool = KeychainWrapper.standard.set(uid, forKey: "uid")
                    
                    guard accessSaveSuccessful && refreshSaveSuccessful && uidSaveSuccessful else {
                        alert("Something went wrong", "Please try again")
                        return
                    }
                    
                    self.switchToMain()
                    
                }
            }
            
        }
        
    } 
    
    //Basically for sign out with Google
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        KeychainWrapper.standard.removeObject(forKey: "access")
        KeychainWrapper.standard.removeObject(forKey: "refresh")
        KeychainWrapper.standard.removeObject(forKey: "uid")
        
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    
    
    
    var window: UIWindow?
    
    func switchToAuth() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        
        self.window?.rootViewController = signInViewController
        self.window?.makeKeyAndVisible()
    }
    
    func switchToMain() {
        let hasPassedInterestsScreen = UserDefaults.standard.bool(forKey: "com.gethighlow.hasPassedInterestsScreen")
        
        if !hasPassedInterestsScreen {
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let mainViewController = InterestsPitchViewController()
            
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
            
        }
        
        else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Tabs", bundle: nil)
            let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            
            self.window?.rootViewController = mainViewController
            self.window?.makeKeyAndVisible()
        }
    }

    func checkAppleAuth() {
        if #available(iOS 13, *) {
            if let userID = KeychainWrapper.standard.string(forKey: "ASAuthorizationUserID") {
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                    
                    if error != nil {
                        KeychainWrapper.standard.removeObject(forKey: "refresh")
                        KeychainWrapper.standard.removeObject(forKey: "access")
                        KeychainWrapper.standard.removeObject(forKey: "uid")
                        KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                        self.switchToAuth()
                    }
                    
                    switch credentialState {
                    case .authorized:
                        break;
                    case .revoked:
                        fallthrough
                    case .notFound:
                        fallthrough
                    default:
                        KeychainWrapper.standard.removeObject(forKey: "refresh")
                        KeychainWrapper.standard.removeObject(forKey: "access")
                        KeychainWrapper.standard.removeObject(forKey: "uid")
                        KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                        self.switchToAuth()
                    }
                    
                }
            } else {
                KeychainWrapper.standard.removeObject(forKey: "refresh")
                KeychainWrapper.standard.removeObject(forKey: "access")
                KeychainWrapper.standard.removeObject(forKey: "uid")
                KeychainWrapper.standard.removeObject(forKey: "ASAuthorizationUserID")
                self.switchToAuth()
            }
        }
    }
    
    func getClientID() -> String? {
        var nsDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            nsDict = NSDictionary(contentsOfFile: path)
            
            return nsDict?.object(forKey: "CLIENT_ID") as? String
        }
        
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        reachability.whenUnreachable = notReachable
        
        do {
            try reachability.startNotifier()
        } catch {
        }
        
        
        
        UserDefaults.standard.setValue(true, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        FirebaseApp.configure()
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        
        if let clientID = getClientID() {
            GIDSignIn.sharedInstance()?.clientID = clientID
        } else { return false }
        
        GIDSignIn.sharedInstance()?.delegate = self
        
        if let _: String = KeychainWrapper.standard.string(forKey: "access") {
            
            if let notificationInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
                
                switchToMain()
                
                if let highlowid = notificationInfo["highlowid"] as? String {
                    NotificationCenter.default.post(name: NSNotification.Name("com.gethighlow.highlowidFromNotification"), object: nil, userInfo: ["highlowid": highlowid])
                }
                else if let uid = notificationInfo["uid"] as? String {
                    let friendsVC = FriendsTableViewController()
                    friendsVC.uid = uid
                    let navCon = UINavigationController(rootViewController: friendsVC)
                    navCon.navigationBar.barStyle = .black
                    navCon.navigationBar.isTranslucent = false
                    navCon.navigationBar.barTintColor = AppColors.primary
                    window?.rootViewController?.present(navCon, animated: true, completion: nil)
                }
            } else {
                //Go to main screen
                switchToMain()
            }
            
            
        } else {
            let hasReceivedTutorial = UserDefaults.standard.bool(forKey: "com.gethighlow.hasReceivedTutorial")
            if !hasReceivedTutorial {
                self.window = UIWindow(frame: UIScreen.main.bounds)
                
                let storyboard = UIStoryboard(name: "Tutorials", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as! TutorialPageViewController
                
                self.window?.rootViewController = mainViewController
                self.window?.makeKeyAndVisible()
            }
            else {
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                
            }
        }
        
        
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let highlowid = userInfo["highlowid"] as? String {
            NotificationCenter.default.post(name: NSNotification.Name("com.gethighlow.highlowidFromNotification"), object: nil, userInfo: ["highlowid": highlowid])
        }
        else if let uid = userInfo["uid"] as? String {
            let friendsVC = FriendsTableViewController()
            friendsVC.uid = uid
            let navCon = UINavigationController(rootViewController: friendsVC)
            navCon.navigationBar.barStyle = .black
            navCon.navigationBar.isTranslucent = false
            navCon.navigationBar.barTintColor = AppColors.primary
            window?.rootViewController?.present(navCon, animated: true, completion: nil)
        }
    }

}

