//
//  HomeViewController.swift
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController {
    
    
    var accToken = ""
    var userID = ""
    var code = ""
    
    var numberOfSongs = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

    }
    
    
    
    var arrOfPlaylists = [String]()
    var arrOfSongs = [String]()
    @IBAction func buttonPressed(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        userID = appDelegate.getUserID()
        code = appDelegate.getCode()
        
        
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
        let headers = [
            "Authorization": "Bearer " + accToken
        ]
        
        
        Alamofire.request(.GET, apiURL, encoding: .JSON, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    for (_, subJson) in json["items"] {
                        if let name = subJson["name"].string {
                            self.arrOfPlaylists.append(name)
                            self.numberOfSongs += 1
                            //self.getAllPlaylists()
                        }
                    }
                    
//                    for (_, subJson) in json["items"] {
//                        if let name = subJson["name"].string {
//                            self.arrOfSongs.append(name)
//                            //self.numberOfSongs += 1
//                        }
//                    }
                }
            case .Failure(let error):
                print(error)
            }
        }

    }
    
//    
//    // ["the stuff", "g", "troye", "Beyonce", "euphemism", "anecdote", "techtonic"]
//    func getAllPlaylists() {
//        
//        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/{playlist_id}/tracks"
//        let headers = [
//            "Authorization" : "Bearer \(accToken)"
//        ]
//        
//        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
//            switch response.result {
//            case .Success:
//                
//                
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    
//                    self.userID = json["id"].stringValue
//                    //self.addTracksToPlaylistUsingUri()
//                    self.createPlaylist()
//                    
//                }
//            case .Failure(let error):
//                print(error)
//            }
//        }
//
//        
//    }
//    

}
