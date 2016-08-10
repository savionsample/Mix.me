//
//  Playlist
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class Playlist
{
    var title: String?
    var description: String
    var thumbnailURL: NSURL?
    var createdAt: String?
    var author: String?
    
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
    
    typealias PlaylistDictionary = [String : AnyObject]
    
    init(espDictionary: PlaylistDictionary)
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
        
        self.createdAt = ""
        self.author = ""
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
    
    static func downloadAllPlaylists(acc: String, id: String, completionBlock: ([Playlist]) -> Void)
    {
        let apiURL = "https://api.spotify.com/v1/users/" + id + "/playlists"
        let headers = [
            "Authorization" : "Bearer " + acc
        ]
        
        Alamofire.request(.GET, apiURL, headers: headers).response { _, _, data, _ in
            var playlists = [Playlist]()
            if let jsonDictionary = NetworkService.parseJSONFromData(data) {
                let playlistDictionaries = jsonDictionary["items"] as! [PlaylistDictionary]
                for dict in playlistDictionaries {
                    let playlist = Playlist(espDictionary: dict)
                    playlists.append(playlist)
                }
            }
            
            completionBlock(playlists)
        }
    }

}

