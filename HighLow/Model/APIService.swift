//
//  APIService.swift
//  HighLow
//
//  Created by Caleb Hester on 6/19/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class APIService {
    let base_url = "https://api.gethighlow.com"
    
    var accessToken: String?
    var refreshToken: String?
    
    static let shared = APIService()
    
    private init() {
        accessToken = KeychainWrapper.standard.string(forKey: "access")
        refreshToken = KeychainWrapper.standard.string(forKey: "refresh")
    }
    
    func signOut() {
        //Emit sign out notification
    }
    
    func authenticate(access: String?, refresh: String?, uid: String?) {
        if access != nil {
            KeychainWrapper.standard.set(access!, forKey: "access")
        }
        if refresh != nil {
            KeychainWrapper.standard.set(refresh!, forKey: "refresh")
        }
        if uid != nil {
            KeychainWrapper.standard.set(uid!, forKey: "uid")
        }
        
        //Emit log in notification
    }
    
    func urlFromMap(_ url: String, _ params: [String: Any]?) -> String {
        if params == nil {
            return base_url + url
        }
        
        var completeUrl = base_url + url
        
        var i = 0
        
        for (key, value) in params! {
            if i == 0 {
                completeUrl += "?"
            }
            
            completeUrl += key + "=" + (value as! String)
            
            i += 1
        }
        
        return completeUrl
    }
    
    func makeRequest(_ url: String, method: HTTPMethod, params: [String: Any]?, onSuccess: @escaping (_ json:
        NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        var completeUrl = ""
        
        if method == .get {
            completeUrl = urlFromMap(url, params)
        } else {
            completeUrl = base_url + url
        }
        
        var finalParams: [String: Any] = [
            "supports_html": true
        ]
        
        if params == nil {
            finalParams.merge(params!, uniquingKeysWith: { (current, _) in current })
        }
            
        AF.request(completeUrl, method: method, parameters: finalParams, encoding: (method == .get ? URLEncoding.queryString:URLEncoding.httpBody)).responseJSON { response in
            switch response.result {
            case .success(let result):
                let json = result as! NSDictionary
                
                if json["error"] != nil {
                    onError(json["error"] as? String ?? "unknown-error")
                    return
                }
                
                onSuccess(json)
                break
            case .failure(let error):
                onError(error.errorDescription ?? "unknown-error")
            }
        }
    }

    func refreshAccess(_ callback: @escaping (_ success: Bool) -> Void) {
        if refreshToken == nil {
            callback(false)
            signOut()
            return
        }
        
        let params: [String: String] = [
            "refresh": refreshToken!
        ]
        
        makeRequest("/auth/refresh_access", method: .post, params: params, onSuccess: { json in
            guard json["access"] != nil else {
                callback(false)
                self.signOut()
                return
            }
            
            self.accessToken = json["access"] as? String
            
            KeychainWrapper.standard.set(self.accessToken!, forKey: "access")
            
            callback(true)
            
        }, onError: { error in
            callback(false)
            self.signOut()
        })
    }
    
    func authenticatedRequest(_ url: String, method: HTTPMethod, params: [String: Any]?, onSuccess: @escaping (_ json:
        NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void) {
        var completeUrl = ""
        
        if method == .get {
            completeUrl = urlFromMap(url, params)
        } else {
            completeUrl = base_url + url
        }
        
        var finalParams: [String: Any] = [
            "supports_html": true
        ]
        
        if params == nil {
            finalParams.merge(params!, uniquingKeysWith: { (current, _) in current })
        }
        
        if accessToken == nil {
            refreshAccess { success in
                guard success else {
                    onError("ERROR-INVALID-REFRESH-TOKEN")
                    return
                }
                self.authenticatedRequest(url, method: method, params: params, onSuccess: onSuccess, onError: onError)
            }
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken!
        ]
            
        AF.request(completeUrl, method: method, parameters: finalParams, encoding: (method == .get ? URLEncoding.queryString:URLEncoding.httpBody), headers: headers).responseJSON { response in
            switch response.result {
            case .success(let result):
                let json = result as! NSDictionary
                
                if let error = json["error"] as? String {
                    
                    if error == "ERROR-INVALID-TOKEN" {
                        self.refreshAccess { success in
                            self.authenticatedRequest(url, method: method, params: params, onSuccess: onSuccess, onError: onError)
                        }
                        return
                    }
                    
                    onError(error)
                    return
                }
                
                onSuccess(json)
                break
            case .failure(let error):
                onError(error.errorDescription ?? "unknown-error")
            }
        }
    }
    
    func authenticatedRequest(_ url: String, method: HTTPMethod, params: [String: Any]?, file: UIImage, onSuccess: @escaping (_ json:
        NSDictionary) -> Void, onError: @escaping (_ error: String) -> Void, onProgressUpdate: @escaping Request.ProgressHandler) {
        var completeUrl = ""
        
        if method == .get {
            completeUrl = urlFromMap(url, params)
        } else {
            completeUrl = base_url + url
        }
        
        var finalParams: [String: Any] = [
            "supports_html": true
        ]
        
        if params == nil {
            finalParams.merge(params!, uniquingKeysWith: { (current, _) in current })
        }
        
        if accessToken == nil {
            refreshAccess { success in
                guard success else {
                    onError("ERROR-INVALID-REFRESH-TOKEN")
                    return
                }
                self.authenticatedRequest(url, method: method, params: params, onSuccess: onSuccess, onError: onError)
            }
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken!
        ]
        
        let imgData = file.jpegData(compressionQuality: 0.7)!
            
        AF.upload(multipartFormData: { multiPartFormData in
            
            multiPartFormData.append(imgData , withName: "file", fileName: "image.JPEG", mimeType: "image/jpeg")
            
            for (key, value) in params! {
                if value is String {
                    multiPartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key )
                }
                else if value is Bool {
                    multiPartFormData.append((value as! Bool).description.data(using: String.Encoding.utf8)!, withName: key )
                }
            }
            
        }, to: url, headers: headers).uploadProgress(queue: .main, closure: onProgressUpdate).responseJSON { response in
                
                switch response.result {
                case .success(let uploadResult):
                    let json = uploadResult as! NSDictionary
                    
                    if let error = json["error"] as? String {
                        
                        if error == "ERROR-INVALID-TOKEN" {
                            //Remove token and ask for a refresh
                            KeychainWrapper.standard.removeObject(forKey: "access")
                            
                            //Refresh token
                            self.refreshAccess({ success in
                                guard success else {
                                    onError("ERROR-INVALID-REFRESH-TOKEN")
                                    self.signOut()
                                    return
                                }
                                self.authenticatedRequest(url, method: method, params: params, file: file, onSuccess: onSuccess, onError: onError, onProgressUpdate: onProgressUpdate)
                                return
                            })
                        }
                        
                        else {
                            onError(error)
                        }
                        
                    } else {
                        
                        //The JSON is clean, and we can callback with the data
                        onSuccess(json)
                        
                    }
                case .failure(let error):
                    onError(error.errorDescription ?? "unknown-error")
                    return
                }
                
            }
    }
}

