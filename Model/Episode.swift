//
//  Episode.swift
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//
import Foundation
import Alamofire
import SwiftyJSON


class Episode
{
    var title: String?
    var description: String?
    var thumbnailURL: NSURL?
    var createdAt: String?
    var author: String?
    //var url: NSURL?
    
    var userID: String
    var accToken: String
    
    init(title: String, description: String, thumbnailURL: NSURL, createdAt: String, author: String)
    {
        self.title = title
        self.description = description
        //self.thumbnailURL = thumbnailURL
        self.createdAt = createdAt
        self.author = author
        
        self.userID = ""
        self.accToken = ""
        
    }
    
    typealias EpisodeDictionary = [String : AnyObject]
    
    init(espDictionary: EpisodeDictionary)
    {
        self.title = espDictionary["name"] as? String

        self.description = espDictionary["id"] as? String
        //print(description)
        
        //self.thumbnailURL = espDictionary["url"] as? String
        //self.thumbnailURL = NSURL(string: espDictionary["images"]!["url"] as! String)
        //print("thumbnail: " + (thumbnailURL?.absoluteString)!)
        self.createdAt = ""
        self.author = ""
        //self.url = NSURL(string: espDictionary["link"] as! String)
        
        self.userID = ""
        self.accToken = ""
        
    }
    

    
    func getAccToken() {
        
        let app = AppDelegate()
        let code = app.getCode()
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
                if let value = response.result.value {
                    let json = JSON(value)
                    self.accToken = json["access_token"].stringValue
                }
            case .Failure(let error):
                print(error)
            }
        }
        
    }
    
    func getUserID() {
        
        let apiURL = "https://api.spotify.com/v1/me"
        let headers = [
            "Authorization" : "Bearer \(accToken)"
        ]
        
        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    self.userID = json["id"].stringValue
                    self.getUsersPlaylists()
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func getUsersPlaylists() {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
        let headers = [
            "Authorization" : "Bearer \(accToken)"
        ]
        
        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    static func downloadAllEpisodes() -> [Episode]
    {
        let apiURL = "https://api.spotify.com/v1/users/" + theUserID() + "/playlists"
        let headers = [
            "Authorization" : "Bearer " + theAccToken()
        ]
        
        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                
                if let value = response.result.value {
                    //let json = JSON(value)
                    //print(json)
                    
                    //let x = jsonToNSData(json)
                }
                
            case .Failure(let error):
                print(error)
            }
            
        }
        
        
        var episodes = [Episode]()
        
        let jsonFile = NSBundle.mainBundle().pathForResource("DucBlog", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonFile!)
        
        if let jsonDictionary = NetworkService.parseJSONFromData(jsonData) {
            let espDictionaries = jsonDictionary["items"] as! [EpisodeDictionary]
            for dict in espDictionaries {
                let episode = Episode(espDictionary: dict)
                episodes.append(episode)
            }
        }
        
        return episodes
    }


}

