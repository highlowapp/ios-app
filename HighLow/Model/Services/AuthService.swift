//
//  AuthService.swift
//  HighLow
//
//  Created by Caleb Hester on 6/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import GoogleSignIn

class AuthService {
    static let shared = AuthService()
    
    var uid: String? 
    
    private init() {
        uid = KeychainWrapper.standard.string(forKey: "uid")
    }
    
    func logOut() {
        //Deregister notifications
        
        KeychainWrapper.standard.removeObject(forKey: "access")
        KeychainWrapper.standard.removeObject(forKey: "refresh")
        KeychainWrapper.standard.removeObject(forKey: "uid")
        
        GIDSignIn.sharedInstance()?.signOut()
        
        APIService.shared.signOut()
        
        self.uid = nil
    }
    
    func signIn(email: String, password: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "email": email,
            "password": password
        ]
        APIService.shared.makeRequest("/auth/sign_in", method: .post, params: params, onSuccess: { json in
            APIService.shared.authenticate(access: json.value(forKey: "access") as? String, refresh: json.value(forKey: "refresh") as? String, uid: json.value(forKey: "uid") as? String)
            self.uid = json.value(forKey: "uid") as? String
            
            onSuccess(json)
        }, onError: onError)
    }
    
    func signUp(firstname: String, lastname: String, email: String, password: String, confirmPassword: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "firstname": firstname,
            "lastname": lastname,
            "email": email,
            "password": password,
            "confirmpassword": confirmPassword
        ]
        
        APIService.shared.makeRequest("/auth/sign_up", method: .post, params: params, onSuccess: { json in
            APIService.shared.authenticate(access: json.value(forKey: "access") as? String, refresh: json.value(forKey: "refresh") as? String, uid: json.value(forKey: "uid") as? String)
            self.uid = json.value(forKey: "uid") as? String
            
            onSuccess(json)
        }, onError: onError)
    }
    
    func forgotPassword(email: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        let params = [
            "email": email
        ]
        
        APIService.shared.makeRequest("/auth/forgot_password", method: .post, params: params, onSuccess: { json in
            onSuccess(json)
        }, onError: onError)
    }
    
    func oauthSignIn(firstname: String?, lastname: String?, email: String?, profileimage: String?, provider_key: String, provider_name: String, onSuccess: @escaping (_ json: NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        var params: [String: String] = [
            "provider_key": provider_key,
            "provider_name": provider_name
        ]
        
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
            params["profileimage"] = profileimage
        }
        
        APIService.shared.makeRequest("/auth/oauth/sign_in", method: .post, params: params, onSuccess: { json in
            APIService.shared.authenticate(access: json.value(forKey: "access") as? String, refresh: json.value(forKey: "refresh") as? String, uid: json.value(forKey: "uid") as? String)
            self.uid = json.value(forKey: "uid") as? String
            
            onSuccess(json)
        }, onError: onError)
    }
    
    func isLoggedIn(ifLoggedIn: @escaping (_ uid: String) -> Void, ifNotLoggedIn: @escaping () -> Void) {
        APIService.shared.authenticatedRequest("/user/isLoggedIn", method: .get, params: nil, onSuccess: { result in
            if let uid = result["uid"] as? String {
                self.uid = uid
                ifLoggedIn(uid)
            } else {
                ifNotLoggedIn()
            }
        }, onError: { error in
            ifNotLoggedIn()
        })
    }
}
