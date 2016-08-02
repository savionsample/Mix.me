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
    var description: String
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
        
        let total = espDictionary["tracks"]!["total"]!
        
        let totalString = String(total!)
        
        if totalString == "1"
        {
         self.description = totalString + " track"
        }
        else
        {
            self.description = totalString + " tracks"
        }
        
        
        
        //self.thumbnailURL = espDictionary["url"] as? String
        //self.thumbnailURL = NSURL(string: espDictionary["images"]!["url"] as! String)
        //print("thumbnail: " + (thumbnailURL?.absoluteString)!)
        self.createdAt = ""
        self.author = ""
        //self.url = NSURL(string: espDictionary["link"] as! String)
        
        self.userID = ""
        self.accToken = ""
        
    }
    
    func getAccToken()
    {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.accToken = delegate.getAccessToken()
    }
    
    func getUserID()
    {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.userID = delegate.getUserID()
    }
    
    
    func returnAccToken() -> String
    {
        return accToken
    }
    
    func returnID() -> String
    {
        return userID
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
                    //print(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    
    static func downloadAllEpisodes(acc: String, id: String, completionBlock: ([Episode]) -> Void)
    {
        let apiURL = "https://api.spotify.com/v1/users/" + id + "/playlists"
        let headers = [
            "Authorization" : "Bearer " + acc
        ]
        
        Alamofire.request(.GET, apiURL, headers: headers).response { _, _, data, _ in
            var episodes = [Episode]()
            if let jsonDictionary = NetworkService.parseJSONFromData(data) {
                let espDictionaries = jsonDictionary["items"] as! [EpisodeDictionary]
                for dict in espDictionaries {
                    let episode = Episode(espDictionary: dict)
                    episodes.append(episode)
                }
            }
            
            completionBlock(episodes)
        }
    }

}

