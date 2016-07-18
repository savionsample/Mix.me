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
        // response.data
        
        var accessToken: JSON = nil
        var userID: String = ""
        
        func getUserID() {
            
            let apiURL = "https://api.spotify.com/v1/me"
            let headers = [
                "Authorization" : "Bearer \(accessToken.stringValue)"
            ]
            
            Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                switch response.result {
                case .Success:
                    
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        userID = json["id"].stringValue
                        createNewPlaylist()

                    }
                case .Failure(let error):
                    print(error)
                }
            }
            
        }
        
        
        func createNewPlaylist() {
            
            let apiURL = "https://api.spotify.com/v1/users/\(userID)playlists"
            let headers = [
                "Authorization" : "Bearer \(accessToken.stringValue)",
                "Content-Type" : "application/json"
            ]
            
            
            Alamofire.request(.GET, apiURL, parameters: ["name":"the new playlist"], encoding: .URL, headers: headers).responseJSON { response in
                switch response.result {
                case .Success:
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json["snapshot_id"])
                        //userID = json["id"].stringValue
                        //createNewPlaylist()
                        
                    }
                case .Failure(let error):
                    print(error)
                }
            }

            
        }

        

        
        Alamofire.request(.POST, "https://accounts.spotify.com/api/token", parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                   let json = JSON(value)
                    
                    
                    accessToken = json["access_token"]
                    getUserID()
                    
                    
                    // let tokenType = json["token_type"]
                    // let scope = json["scope"]
                    // let expiration = json["expires_in"]
                    // let refreshToken = json["refresh_token"]
                    
                }
            case .Failure(let error):
                print(error)
            }
        }

        
        print("3")
        
        
        // get the user's ID
        //print("OK" + accessToken.stringValue)
      
        
//        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers)
//            .responseJSON { response in
//                
//        }
        
        
        
        
        
        
        
        
     return true
    }

}

