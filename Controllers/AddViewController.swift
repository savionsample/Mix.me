//
//  AddViewController.swift
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Whisper

class AddViewController: UIViewController, UIPickerViewDelegate {
    
    var accToken = ""
    var artistID = ""
    var userID = ""
    var newPlaylistID = ""
    var artist = ""
    var playlistName = ""
    
    var arrOfURI = [String]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userTextField: UITextField!
    
    @IBOutlet weak var userTextField2: UITextField!
    @IBAction func hideKeyboard(sender: AnyObject) {
        userTextField.resignFirstResponder()
    }
    
    
    @IBAction func hiddenButton(sender: AnyObject) {
        userTextField.resignFirstResponder()
        userTextField2.resignFirstResponder()
    }

    @IBAction func playlistButtonPressed(sender: AnyObject) {
        
        artist = self.userTextField.text!
        playlistName = self.userTextField2.text!
        
        
        let replaced = String(artist.characters.map {
            $0 == " " ? "+" : $0
        })
        
        // GET ARTIST'S ID
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=\(replaced)&type=artist").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value
                {
                    let json = JSON(value)
                    
                    if (json["artists"]["items"][0]["id"].stringValue != "")
                    {
                        self.whisperMessage("Spotify playlist created!")
                        self.artistID = json["artists"]["items"][0]["id"].stringValue
                        self.retrieveUriOfArtistsTracks()
                        
                    }
                    else
                    {
                        self.whisperMessage("Make sure there's a valid artist and a name for the playlist")
                    }
                    
                }
            case .Failure(_):
                self.whisperMessage("There was an error in creating your playlist. Please try again.")
            }
        }
    }
    

    

    
    func retrieveUriOfArtistsTracks()
    {
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/\(artistID)/top-tracks?country=US").validate().responseJSON { response in
            switch response.result {
            case .Success:
                print("2")
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    for (_, subJson) in json["tracks"] {
                        if let uri = subJson["uri"].string {
                            self.arrOfURI.append(uri)
                        }
                    }
                    
                    self.getUserID()
                    
                    
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
                print("3")
                
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    self.userID = json["id"].stringValue
                    //self.addTracksToPlaylistUsingUri()
                    self.createPlaylist()
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func createPlaylist() {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
        let headers = [
            "Authorization": "Bearer " + accToken,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: AnyObject] = [
            "name": playlistName
        ]
        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                print("4")
                if let value = response.result.value {
                    let json = JSON(value)
                     self.newPlaylistID = json["id"].stringValue
                    self.addTracksToPlaylistUsingUri()
                    
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func addTracksToPlaylistUsingUri() {
        print("5")
        
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/\(newPlaylistID)/tracks"
        let headers = [
            "Authorization" : "Bearer " + accToken
        ]
        let parameters: [String: AnyObject] = [
            "uris": arrOfURI
        ]
        
        print(arrOfURI)

        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add from Artist"
        scrollView.contentSize.height = 300
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "exit")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "exit")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)


        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        
    }
    
    func whisperMessage(message: String)
    {
        let message = Message(title: message, backgroundColor: UIColor(red: 110/255.0, green: 185/255.0, blue: 159/255.0, alpha: 1.0))
        Whisper(message, to: navigationController!, action: .Show)
    }

    
    
    
    
}
