//
//  Playlist.swift
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//
/*
import Foundation
import Alamofire
import SwiftyJSON


class Track
{
    var title: String?
    var description: String
    var userID: String
    var accToken: String

    typealias TrackDictionary = [String : AnyObject]

    
    init(title: String, description: String)
    {
        self.title = title
        self.description = description
        self.userID = ""
        self.accToken = ""
    }

    
    init(trackDictionary: TrackDictionary)
    {
        self.title = trackDictionary["name"] as? String
        self.description = ""
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
    
    
    
/*
    func getPlaylistsTracks()
    {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/\(playlistId)/tracks"
        let headers = [
            "Authorization" : "Bearer \(accToken)"
        ]
        
        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let parentJSON = JSON(value)
                    guard let json = parentJSON["items"].array else { print("\(parentJSON) not an array"); return }
                    
                    self.arrOfURIPlaylist = json.flatMap { subJSON in
                        let trackJSON = subJSON["track"]
                        return trackJSON["uri"].string
                    }
                    
                    self.arrOfTracks = json.flatMap { subJSON in
                        let trackJSON = subJSON["track"]
                        return trackJSON["duration_ms"].int
                    }
                    
                    for i in 0..<self.arrOfURIPlaylist.count
                    {
                        self.songLinks.append(SongLink(uri: self.arrOfURIPlaylist[i], songLength: self.arrOfTracks[i]))
                    }
                    
                    self.shuffle()
                    self.calculateClosestTime()
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
*/

    
    static func downloadAllPlaylists(acc: String, id: String, completionBlock: ([Track]) -> Void)
    {
        let apiURL = "https://api.spotify.com/v1/users/" + id + "/playlists"
        let headers = [
            "Authorization" : "Bearer " + acc
        ]
        
        Alamofire.request(.GET, apiURL, headers: headers).response { _, _, data, _ in
            var tracks = [Track]()
            if let jsonDictionary = NetworkService.parseJSONFromData(data) {
                let trackDictionaries = jsonDictionary["items"] as! [TrackDictionary]
                for dict in trackDictionaries {
                    let track = Track(trackDictionary: dict)
                    tracks.append(track)
                }
            }
            
            completionBlock(tracks)
        }
    }
    
}
*/
