//
//  ViewController.swift
//  AFSample
//
//  Created by Savion Sample on 7/12/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// let json = JSON(data: dataFromNetworking)
// let json = JSON(jsonObject)
//if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
//    let json = JSON(data: dataFromString)
//}

class ViewController: UIViewController {
    
    private var foregroundNotification: NSObjectProtocol!
    
    
    //@IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: "https://accounts.spotify.com/authorize/" +
        "?client_id=08058b3b809047579419282718defac6" +
        "&response_type=code" +
        "&redirect_uri=mixme%3A%2F%2Freturnafterlogin" +
        "&scope=playlist-modify-public" +
        "%20user-read-private"){
            UIApplication.sharedApplication().openURL(url)
            
            foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
                [unowned self] notification in
                
                
                self.performSegueWithIdentifier("gotoTab", sender: nil)
                
                // do whatever you want when the app is brought back to the foreground
                //let tabBarController = tabBarController
                
            }
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundCity.jpg")!)
        
        
        var dictOfEverything = [String : Int]()
        var arrOfNames = [String]()
        var arrOfTimes = [Int]()
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/1uNFoZAHBGtllmzznpCI3s/top-tracks?country=US").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    //print("JSON: \(json)")
                    
                    for (_, subJson) in json["tracks"] {
                        if let name = subJson["name"].string {
                            arrOfNames.append(name)
                        }
                    }
                    
                    for (_, subJson) in json["tracks"] {
                        if let time = subJson["duration_ms"].int {
                            arrOfTimes.append(time)
                        }
                    }
                    
                    for i in 0..<10 {
                        let key = arrOfNames[i]
                        let value = arrOfTimes[i]
                        dictOfEverything[key] = value
                    }
                    
                    // 35 mins, 2144503 ms
                    //print(dictOfEverything)
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}