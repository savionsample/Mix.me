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

class ViewController: UIViewController {
    
    private var foregroundNotification: NSObjectProtocol!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: "https://accounts.spotify.com/authorize/" +
        "?client_id=08058b3b809047579419282718defac6" +
        "&response_type=code" +
        "&redirect_uri=mixme%3A%2F%2Freturnafterlogin" +
        "&scope=playlist-modify-public" +
        "%20user-read-private") {
            UIApplication.sharedApplication().openURL(url)
            
            // perform segue to next View when returning after signing in
            foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
                [unowned self] notification in

                self.performSegueWithIdentifier("gotoTabFromSingleView", sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}