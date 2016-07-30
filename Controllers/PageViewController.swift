//
//  ViewController.swift
//  UIPageViewController
//
//  Created by PJ Vea on 3/27/15.
//  Copyright (c) 2015 Vea Software. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON

class PageViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    var accToken: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //refreshView()
        if accToken.characters.count > 0
        {
            print("aldkfadfkl")
            foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            
            self.performSegueWithIdentifier("gotoTabFromMultiView", sender: nil)
            }
            
        }
        
        self.pageTitles = NSArray(objects: "Explore", "Keep your playlists updated", "")
        self.pageImages = NSArray(objects: "page1", "page2", "backgroundCity")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, -5, self.view.frame.width, self.view.frame.size.height - 60)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        
    }
    
     private var foregroundNotification: NSObjectProtocol!
    
    @IBAction func likeButtonTapped(sender: AnyObject)
    {
        
        let pageURL = "https://accounts.spotify.com/authorize/" +
            "?client_id=08058b3b809047579419282718defac6" +
            "&response_type=code" +
            "&redirect_uri=mixme%3A%2F%2Freturnafterlogin" +
            "&scope=playlist-modify-public" +
            "%20user-read-private"
        
        if let url = NSURL(string: pageURL)
        {
            UIApplication.sharedApplication().openURL(url)

            // perform segue to next View when returning after signing in
            foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
                [unowned self] notification in
                
                self.performSegueWithIdentifier("gotoTabFromMultiView", sender: nil)
            }
            
   
        }
        
    
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
//    {
//        // import SafariServices
//        let safariVC = SFSafariViewController(URL: NSURL(string: "https://accounts.spotify.com/authorize/?client_id=08058b3b809047579419282718defac6&response_type=code&redirect_uri=mixme%3A%2F%2Freturnafterlogin&scope=playlist-modify-public")!)
//
//        safariVC.view.tintColor = UIColor(red: 248/255.0, green: 47/255.0, blue: 38/255.0, alpha: 1.0)
//        safariVC.delegate = self
//        self.presentViewController(safariVC, animated: true, completion: nil)
//    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewControllerAtIndex(index: Int) -> ContentViewController
    {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
        
        
    }
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index += 1
        
        if (index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    
    func refreshView()
    {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let refresh = delegate.getRefreshToken()
        
        let apiURL = "https://accounts.spotify.com/api/token"
        
        let parameters: [String: AnyObject] = [
            "grant_type": "refresh_token",
            "refresh_token": refresh,
            "client_id": "08058b3b809047579419282718defac6",
            "client_secret": "0d3414e646f54b7186a795ed559570b7"
        ]
        
        
        Alamofire.request(.POST, apiURL, parameters: parameters, encoding: .JSON).responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.accToken = json["access_token"].stringValue
                    print(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var subViews: NSArray = view.subviews
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil
        
        for view in subViews {
            if view.isKindOfClass(UIScrollView) {
                scrollView = view as? UIScrollView
            }
            else if view.isKindOfClass(UIPageControl) {
                pageControl = view as? UIPageControl
            }
        }
        
        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    }
    
}

extension EpisodesTableViewController : SFSafariViewControllerDelegate
{
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}


