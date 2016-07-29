//
//  EpisodeTableViewController.swift
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import SafariServices
import LiquidFloatingActionButton

class EpisodesTableViewController: UITableViewController
{
    var episodes = [Episode]()
    var cells = [LiquidFloatingCell]() // data sourc
    var floatingActionButton: LiquidFloatingActionButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        createFloatingButton()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        //self.episodes = Episode.downloadAllEpisodes()
        self.tableView.reloadData()
        self.tableView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        
        
        
        
    }
    
    private func createFloatingButton()
    {
        cells.append(createButtonCell("addFromPlaylist"))
        cells.append(createButtonCell("addFromArtist"))
        cells.append(createButtonCell("ic_place"))

        let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        let floatingButton = createButton(floatingFrame, style: .Up)
        self.view.addSubview(floatingButton)
        self.floatingActionButton = floatingButton
    }
    
    private func createButtonCell(iconName: String) -> LiquidFloatingCell
    {
        return LiquidFloatingCell(icon: UIImage(named: iconName)!)
    }
    
    private func createButton(frame: CGRect, style: LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton
    {
        let floatingActionButton = LiquidFloatingActionButton(frame: frame)
        
        floatingActionButton.animateStyle = style
        //floatingActionButton.dataSource = self
        //floatingActionButton.delegate = self
        
        return floatingActionButton
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .Default
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return episodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Episode Cell", forIndexPath: indexPath) as! EpisodeTableViewCell
        let episode = self.episodes[indexPath.row]
        
        cell.episode = episode
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:
//        NSIndexPath)
//    {
//        let selectedEpisode = self.episodes[indexPath.row]
//        
//        // import SafariServices
//        let safariVC = SFSafariViewController(URL: selectedEpisode.url!)
//        safariVC.view.tintColor = UIColor(red: 248/255.0, green: 47/255.0, blue: 38/255.0, alpha: 1.0)
//        safariVC.delegate = self
//        self.presentViewController(safariVC, animated: true, completion: nil)
//    }
//    
}

//extension EpisodesTableViewController : SFSafariViewControllerDelegate
//{
//    func safariViewControllerDidFinish(controller: SFSafariViewController) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
//}

//extension EpisodesTableViewController: LiquidFloatingActionButtonDataSource
//{
//    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int
//    {
//        return cells.count
//    }
//    
//    func cellForIndex(index: Int) -> LiquidFloatingCell
//    {
//        return cells[index]
//    }
//}
//
//extension EpisodesTableViewController: LiquidFloatingActionButtonDelegate
//{
//    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int)
//    {
//        print("button number \(index) did click")
//        
//        if index == 1
//        {
////            self.performSegueWithIdentifier("", sender: self)
//            
//        }
//        self.floatingActionButton.close()
//    }
//}




