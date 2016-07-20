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

        
        let parameters: [String: AnyObject] = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri": "mixme://returnafterlogin",
            "client_id": "08058b3b809047579419282718defac6",
            "client_secret": "0d3414e646f54b7186a795ed559570b7"
        ]
        
        var accessToken: JSON = nil
        var userID: String = ""
        
        
        // GET THE USER'S ID
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
                        // userPlaylists()
                        //createNewPlaylist()
                        addTracksToPlaylist()

                    }
                case .Failure(let error):
                    print(error)
                }
            }
            
        }
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        // CREATE A NEW PLAYLIST WITH ALL OF THE CREDENTIALS
        func createNewPlaylist() {
            
            let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
            let headers = [
                "Authorization": "Bearer " + accessToken.stringValue,
                "Content-Type": "application/json"
            ]
            
            let parameters: [String: AnyObject] = [
                "name": "Rock Music",
                "public": "true"
            ]

            Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .URL, headers: headers).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON: \(json)")
    
                        //print(json["collaborative"])
                    }
                case .Failure(let error):
                    print(error)
                }
            }

            
        }
        
        
        
        
        
        // GET DETAILS ABOUT USER'S PLAYLISTS
        func userPlaylists() {
            
            let apiURL = "https://api.spotify.com/v1/users/savionsample/playlists"
            let headers = [
                "Authorization" : "Bearer " + accessToken.stringValue
            ]

            Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print("JSON: \(json)")
                        
                        //print(json["collaborative"])
                    }
                case .Failure(let error):
                    print(error)
                }
            }
            
            
        }
        
        
        
        
        
        // ADD TRACKS TO PLAYLISTS
        func addTracksToPlaylist() {
            
            let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/15y711eyGYKzleFvUQwrth/tracks"
            let headers = [
                "Authorization" : "Bearer " + accessToken.stringValue
            ]
            let parameters: [String: AnyObject] = [
                "uris": [
                    "spotify:track:4iV5W9uYEdYUVa79Axb7Rh",
                    "spotify:track:1301WleyT98MSxVHPZCA6M"]
            ]
            
            Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print("JSON: \(json)")
                        
                        print(json["collaborative"])
                    }
                case .Failure(let error):
                    print(error)
                }
            }
            
            
        }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
        

        Alamofire.request(.POST, "https://accounts.spotify.com/api/token", parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                   let json = JSON(value)
                
                    accessToken = json["access_token"]
                    let scope = json["scope"]
                    print("JSON: \(json)")
                    
                    print("the scope" + scope.stringValue)
                    getUserID()
                    
                    
                    // let tokenType = json["token_type"]
                    
                    // let expiration = json["expires_in"]
                    // let refreshToken = json["refresh_token"]
                    
                    
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
     return true
    }

}

