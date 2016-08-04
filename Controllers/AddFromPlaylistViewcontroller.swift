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

class AddFromPlaylistViewController: UIViewController
{
    var accToken = ""
    var artistID = ""
    var userID = ""
    var playlistName = ""
    var length = 0
    
    struct SongLink {
        let uri: String
        let songLength: Int
    }
    
    var arrOfURIPlaylist = [String]()
    var finalUriToAdd = [String]()
    var arrOfTracks = [Int]()
    var arrOfIndexes = [Int]()
    var dictUriMS = [String: Int]()
    var songLinks = [SongLink]()
    
    private var foregroundNotification: NSObjectProtocol!
    
    @IBOutlet weak var existingPlaylistName: UITextField!
    @IBOutlet weak var newPlaylistName: UITextField!
    @IBOutlet weak var lengthText: UITextField!
    
    @IBAction func hideText(sender: AnyObject)
    {
        existingPlaylistName.resignFirstResponder()
        newPlaylistName.resignFirstResponder()
        lengthText.resignFirstResponder()
    }
    
    @IBAction func playlistButtonPressed(sender: AnyObject)
    {
        let artist = self.existingPlaylistName.text!
        playlistName = self.newPlaylistName.text!
        length = Int(self.lengthText.text!)!
        
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
                        self.sendAlert("Spotify playlist created!")
                        self.artistID = json["artists"]["items"][0]["id"].stringValue
                        self.getUserID()
                    }
                    else
                    {
                        self.sendAlert("Make sure there's a valid artist and a name for the playlist")
                    }
                    
                }
            case .Failure(_):
                self.sendAlert("There was an error in creating your playlist. Please try again.")
            }
        }
        
    }
    
    func shuffle()
    {
        songLinks.sortInPlace { _, _ in arc4random() > arc4random() }
    }
    
    
    // ????
    func textView(textView: UITextView!, shouldChangeTextInRange: NSRange, replacementText: NSString!) -> Bool {
        if(replacementText == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
                    self.getPlaylistsTracks()
                    
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
                    let json = JSON(value)
                    //print(json)
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    
    
    func getPlaylistsTracks()
    {
        let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/1QT46jx1BB1sNM6yvu7Jdz/tracks"
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
                    
                    self.dictUriMS = [String: Int]()

                    for i in 0..<self.arrOfURIPlaylist.count
                    {
                        self.songLinks.append(SongLink(uri: self.arrOfURIPlaylist[i], songLength: self.arrOfTracks[i]))
                        //self.dictUriMS[self.arrOfURIPlaylist[i]] = self.arrOfTracks[i]
                    }

                    self.shuffle()
                    self.calculateClosestTime()
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
    

    
    var newPlaylistID = ""
    
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
            ///
        }
        arrOfURIPlaylist = []
        finalUriToAdd = []
        //getPlaylistsTracks()
    }
    
    func sendAlert(message: String)
    {
        let alertController = UIAlertController(title: "Proccess completed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        //myTimePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        
        //theScrollView.contentSize.height = 700
        self.title = "Add From Artist"
        
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
