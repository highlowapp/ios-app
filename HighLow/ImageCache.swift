//
//  ImageCache.swift
//  HighLow
//
//  Created by Caleb Hester on 6/13/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage


public class ImageCache {
    
    static var cache = NSCache<NSString, UIImage>()
    
    static func getImage(_ url: String, onSuccess success: @escaping (_ image: UIImage) -> Void, onError error: @escaping () -> Void) {
        
        //Check the cache for the image
        if let cachedImage = cache.object(forKey: (url as NSString)) {
            success(cachedImage)
            return
        }
        
        //If the image didn't exist, make a request to fetch it
        Alamofire.request(url).responseImage { response in
            
            if let image = response.result.value {
                
                //Cache the newly-requested image
                self.cache.setObject(image as UIImage, forKey: url as NSString)
                
                //Run callback with image
                success(image as UIImage)
                
            }
            
            else {
                error()
            }
            
        }
        
    }
    
    static func cacheImage(_ url: String, image: UIImage) {
        
        self.cache.setObject(image as UIImage, forKey: url as NSString)
        
    }
    
}
