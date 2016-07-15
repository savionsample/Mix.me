//
//  AppDelegate.swift
//  AFSample
//
//  Created by Savion Sample on 7/12/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var code: String = ""

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    
    func application(application: UIApplication, openURL: NSURL, options: [String: AnyObject]) -> Bool {
        
        // get only the "code" part of the returned URL required for Spotify Authentification
        let returnLink = openURL.absoluteString
        let indexStartOfText = returnLink.startIndex.advancedBy(31)
        code = returnLink.substringFromIndex(indexStartOfText)
        
       
//        Alamofire.request(.POST, "https://accounts.spotify.com/api/token/?grant_type=authorization_code&code=\(code)&redirect_uri=mixme%3A%2F%2Freturnafterlogin&client_id=08058b3b809047579419282718defac6&client_secret=0d3414e646f54b7186a795ed559570b7").validate().responseJSON { response in

        
        let parameters: [String: AnyObject] = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri": "mixme://returnafterlogin",
            "client_id": "08058b3b809047579419282718defac6",
            "client_secret": "0d3414e646f54b7186a795ed559570b7"
        ]
        
        
        Alamofire.request(.POST, "https://accounts.spotify.com/api/token", parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let _ = response.result.value {
                   print(response.data)
                }
            case .Failure(let error):
                print(error)
            }
        }
     return true
    }
    
   

}

