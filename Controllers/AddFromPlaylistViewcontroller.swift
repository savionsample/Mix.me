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

class AddFromPlaylistViewController: UIViewController
{
    var accToken = ""
    var artistID = ""
    var userID = ""
    var playlistName = ""
    var playlistId = ""
    var existingPlaylistName = ""
    var newPlaylistName = ""
    var newPlaylistID = ""
    
    var length = 0
    
    var arrOfURIPlaylist = [String]()
    var finalUriToAdd = [String]()
    var arrOfTracks = [Int]()
    var arrOfIndexes = [Int]()
    var dictUriMS = [String: Int]()
    var songLinks = [SongLink]()
    var trackLinks = [TrackLink]()
    
    private var foregroundNotification: NSObjectProtocol!
    
    struct TrackLink {
        let id: String
        let name: String
    }
    
    struct SongLink {
        let uri: String
        let songLength: Int
    }
    
    
    @IBOutlet weak var existingPlaylistTextField: UITextField!
    @IBOutlet weak var newPlaylistTextField: UITextField!
    @IBOutlet weak var lengthText: UITextField!
    
    @IBAction func hideText(sender: AnyObject)
    {
        existingPlaylistTextField.resignFirstResponder()
        newPlaylistTextField.resignFirstResponder()
        lengthText.resignFirstResponder()
    }
    
    @IBAction func playlistButtonPressed(sender: AnyObject)
    {
        existingPlaylistName = self.existingPlaylistTextField.text! ?? "arandomplaylistnamethatwillcausethistofailsoenteryourdamnnamealready"
        newPlaylistName = self.newPlaylistTextField.text!
        
        if let input = self.lengthText.text {
            if input.characters.count == 0 {
                length == 0
            }
            else
            {
                length = Int(self.lengthText.text!)!
            }
        }
        
        
        
        if newPlaylistName == ""
        {
            newPlaylistName = "Unnamed Playlist"
        }
        


        self.getUserID()
    }
    
    func getUserID()
    {
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
    
    func getUsersPlaylists()
    {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
        let headers = [
            "Authorization" : "Bearer \(accToken)"
        ]
        
        Alamofire.request(.GET, apiURL, parameters: nil, encoding: .URL, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let parentJSON = JSON(value)
                    
                    var arrOfNames = [String]()
                    var arrOfId = [String]()
                    
                    
                    for (_, subJson) in parentJSON["items"] {
                        if let name = subJson["name"].string {
                            arrOfNames.append(name)
                        }
                    }
                    
                    for (_, subJson) in parentJSON["items"] {
                        if let id = subJson["id"].string {
                            arrOfId.append(id)
                        }
                    }

                    // append the name/id pairing
                    for i in 0..<arrOfNames.count
                    {
                        self.trackLinks.append(TrackLink(id: arrOfId[i], name: arrOfNames[i]))
                    }
                    
                    // assign the playlist id the user wants
                    for playlist in self.trackLinks
                    {
                        if self.existingPlaylistName == playlist.name
                        {
                            self.playlistId = playlist.id
                        }
                    }
                    
                    // don't continue if the user entered an invalid playlist name
                    if self.playlistId == ""
                    {
                        self.whisperMessage("Invalid existing playlist name")
                    }
                    else
                    {
                        self.getPlaylistsTracks()
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
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
                    
                    var totalLength = 0
                    
                    for i in 0..<self.arrOfTracks.count
                    {
                        totalLength += self.songLinks[i].songLength
                    }
                    
                    if ( (self.length * 60000) > totalLength)
                    {
                        self.whisperMessage("Requested length exceeds playlist's length")
                    }
                    else
                    {
                        self.whisperMessage("Spotify playlist created!")
                        self.shuffle()
                        self.calculateClosestTime()
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func calculateClosestTime()
    {
        let padding = 10000
        let low = (length * 60000) - padding
        let high = (length * 60000) + padding
        
        var totalTime = 0
        
        var i = 0
        while i != songLinks.count && (  totalTime < low || totalTime > high  )
        {
            //let songLength = Int(Array(dictUriMS.values)[i])
            //let songURI = Array(dictUriMS.keys)[i]
            
            let songLength = songLinks[i].songLength
            let songURI = songLinks[i].uri
            
            // when it gets to the last song, see if it's closer to just add the song or leave it out
            if i == songLinks.count - 1
            {
                let totalWithLastSong = totalTime + songLength
                if abs(length - totalWithLastSong) < abs(length - totalTime)
                {
                    finalUriToAdd.append(songURI)
                }
            }
            else if !(totalTime + songLength > high)
            {
                totalTime += songLength
                finalUriToAdd.append(songURI)
            }
            i += 1
        }
        createPlaylist()
    }
    
    func createPlaylist()
    {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists"
        let headers = [
            "Authorization": "Bearer " + accToken,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: AnyObject] = [
            "name": newPlaylistName
        ]
        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            switch response.result {
            case .Success:
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
    
    func addTracksToPlaylistUsingUri()
    {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/\(newPlaylistID)/tracks"
        let headers = [
            "Authorization" : "Bearer " + accToken
        ]

        let parameters: [String: AnyObject] = [
            "uris": finalUriToAdd
        ]
        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            // don't remove comment or else will self destruct
        }
        arrOfURIPlaylist = []
        finalUriToAdd = []
    }

    func whisperMessage(message: String)
    {
        let message = Message(title: message, backgroundColor: UIColor(red: 110/255.0, green: 185/255.0, blue: 159/255.0, alpha: 1.0))
        Whisper(message, to: navigationController!, action: .Show)
    }
    
    // shuffle the array of songs in the playlist
    func shuffle()
    {
        songLinks.sortInPlace { _, _ in arc4random() > arc4random() }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        
        //theScrollView.contentSize.height = 700
        self.title = "Add From Playlist"
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "exit")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "exit")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


