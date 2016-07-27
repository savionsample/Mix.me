//
//  User.swift
//  Mix.me
//
//  Created by Savion Sample on 7/20/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import Foundation

class User {
    var accToken = ""
    dynamic var refreshToken = ""
    var userID = ""
    
//    
//    init(accToken: String, refreshToken: String, userID: String)
//    {
//        self.accToken = accToken
//        self.refreshToken = refreshToken
//        self.userID = userID
//        
//    }
//    
//    typealias EpisodeDictionary = [String : AnyObject]
//    
//    init(espDictionary: EpisodeDictionary)
//    {
//        self.name = espDictionary["name"] as? String
//        self.numTracks = espDictionary["tracks"]!["total"] as? String
//        self.thumbnailURL = NSURL(string: espDictionary["thumbnailURL"] as! String)
//        
//    }
//    
    
    func setAccToken(access: String) {
        accToken = access
    }
    
    func setRefreshToken(refresh: String) {
        refreshToken = refresh
    }
    
    func getAccToken() -> String {
        return accToken
    }
    
//    
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    accToken = appDelegate.getAccessToken()
    
    
}