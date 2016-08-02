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

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var accToken = ""
    var artistID = ""
    var userID = ""
    var playlistName = ""
    var arrOfURIArtist = [String]()
    var arrOfURIPlaylist = [String]()
    var arrOfTracks = [Int]()
    
    var double = [String: Int]()
    
    var currentPickerItem = 0
    
    private var foregroundNotification: NSObjectProtocol!
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var userTextField2: UITextField!
    @IBOutlet weak var myTimePicker: UIPickerView!
    @IBOutlet weak var theScrollView: UIScrollView!
    
    @IBAction func hideKeyboard(sender: AnyObject) {
        userTextField.resignFirstResponder()
    }
    
    @IBAction func hideKeyBoard2(sender: AnyObject) {
        userTextField.resignFirstResponder()
    }

    @IBAction func hiddenButton(sender: AnyObject) {
        userTextField.resignFirstResponder()
        userTextField2.resignFirstResponder()
    }
    
    @IBAction func playlistButtonPressed(sender: AnyObject) {
        
        let artist = self.userTextField.text!
        playlistName = self.userTextField2.text!
        
        let replaced = String(artist.characters.map {
            $0 == " " ? "+" : $0
        })

        // GET ARTIST'S ID
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=\(replaced)&type=artist").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    
                    if (json["artists"]["items"][0]["id"].stringValue != "") {
                        
                        let alertController = UIAlertController(title: "iOScreator", message:
                            "Spotify playlist created!", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.artistID = json["artists"]["items"][0]["id"].stringValue
                        self.retrieveUriOfArtistsTracks()
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "iOScreator", message:
                            "Make sure there's a valid artist and a name for the playlist", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            case .Failure(_):
                let alertController = UIAlertController(title: "iOScreator", message:
                    "There was an error in creating your playlist. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func retrieveUriOfArtistsTracks()
    {
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/\(artistID)/top-tracks?country=US").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)

                    for (_, subJson) in json["tracks"] {
                        if let uri = subJson["uri"].string {
                            self.arrOfURIArtist.append(uri)
                        }
                    }
                    
                    
                    self.getUserID()
                    
                                                            
                }
            case .Failure(let error):
                print(error)
            }
        }
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
                    //self.addTracksToPlaylistUsingUri()
                    self.createPlaylist()
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
        //let apiURL = "https://api.spotify.com/v1/users/\(userID)/playlists/1QT46jx1BB1sNM6yvu7Jdz/tracks/?" +
            "fields=items(track(duration_ms), items(track(uri)"
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
                    
                    self.double = [String: Int]()
                    
                    
                    for i in 0..<self.arrOfURIPlaylist.count
                    {
                        self.double[self.arrOfURIPlaylist[i]] = self.arrOfTracks[i]
                    }
                    print(self.double)
                    
                    
                    
                    
                    
                    
                    /// oohh you can light my candleeeeeeeeeee it went out again
                    // gentlemen, we gather here today 

                    //print(self.arrOfURIPlaylist)
                    //print(self.arrOfTracks)

                    // let fol = self.calculateClosestTime(amount: 600000, coins: self.arrOfTracks)
                    //let fol = self.calculateClosestTime(amount: 20, coins: [1,2,3])

                    //print(fol)
                }
            case .Failure(let error):
                print(error)
            }
        }
        

        
    }
    
    
    func calculateClosestTime()
    {
        let padding = 20000
        
        
        var finalDict = [Int]()
        
        let low = currentPickerItem - padding
        let high = currentPickerItem + padding
        var totalTime = 0
        
        var arrOfIndexes = [Int]()
        
        
        var i = 0
        while totalTime < low || totalTime > high
        {
            if !(totalTime + arrOfTracks[i] > high)
            {
                finalDict.append(arrOfTracks[i])
                arrOfIndexes.append(i)
            }
            i += 1
            
        }
        
        
        
        
    
    
    
    
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////
    
//    var arr = [Int]()
//    
//    func calculateClosestTime(amount amount: Int, coins: [Int]) -> Int
//    {0//        let numbers = [3,9,8,4,5,7,10]
//        let target = 15;
//        sum_up(numbers,target: target);
//    
//    }
//    
//    func sum_up_recursive(numbers: [Int], target: Int, partial: [Int])
//    {
//        var s = 0
//        for x in partial
//        {
//            s += x
//        }
//        if s == target
//        {
//            print(partial)
//        }
//        if s >= target
//        {
//            return
//        }
//        for i in 0...numbers.count
//        {
//            var remaining = [Int]()
//            var n = numbers[i]
//            for j in (i + 1)...numbers.count
//            {
//                remaining.append(numbers[j])
//                var partial_rec = remaining
//                partial_rec.append(n)
//                let emptyArr2: [Int]
//                //sum_up_recursive(remaining, target: Int, partial: emptyArr2)
//            }
//            
//        }
//        
//
//    }
//    
//    func sum_up(numbers: [Int], target: Int)
//    {
//        let emptyArr: [Int]
//        sum_up_recursive(numbers,target: target,partial: emptyArr)
//    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    
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
            "uris": arrOfURIArtist
        ]
        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
            ///
        }
        arrOfURIArtist = []
        
        getPlaylistsTracks()
    }
    

    
    
    var pickerData = ["1 minute", "2 minutes", "3 minutes", "4 minutes", "5 minutes", "6 minutes", "7 minutes", "8 minutes", "9 minutes", "10 minutes", "11 minutes", "12 minutes", "13 minutes", "14 minutes", "15 minutes", "16 minutes", "17 minutes", "18 minutes", "19 minutes", "20 minutes", "21 minutes", "22 minutes", "23 minutes", "24 minutes", "25 minutes", "26 minutes", "27 minutes", "28 minutes", "29 minutes", "30 minutes", "31 minutes", "32 minutes", "33 minutes", "34 minutes", "35 minutes", "36 minutes"]
    
    override func viewDidLoad()
    {
        //myTimePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        super.viewDidLoad()
        
        
        
        self.myTimePicker.delegate = self
        self.myTimePicker.dataSource = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        
        theScrollView.contentSize.height = 700
        self.title = "Add From Artist"
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "exit")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "exit")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // the data returned when chosen
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentPickerItem = Int(pickerData[row])!
        print(pickerData[row])
    }

}
