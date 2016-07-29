//
//  EpisodesViewController
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import SafariServices
import LiquidFloatingActionButton

class EpisodesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var episodes = [Episode]()
    var cells = [LiquidFloatingCell]() // data source
    
    var floatingActionButton: LiquidFloatingActionButton!

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 100.0)
        
        createFloatingButton()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None

        self.episodes = Episode.downloadAllEpisodes()
        self.tableView.reloadData()
        self.tableView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }
    
    private func createFloatingButton()
    {
        cells.append(createButtonCell("addFromPlaylist"))
        cells.append(createButtonCell("addFromArtist"))
        //cells.append(createButtonCell("ic_place"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        let floatingButton = createButton(floatingFrame, style: .Up)
        self.view.addSubview(floatingButton)
        self.floatingActionButton = floatingButton
           
        // logo in nav bar at top
        let logo = UIImage(named: "logoText")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    private func createButtonCell(iconName: String) -> LiquidFloatingCell
    {
        return LiquidFloatingCell(icon: UIImage(named: iconName)!)
    }
    
    private func createButton(frame: CGRect, style: LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton
    {
        let floatingActionButton = LiquidFloatingActionButton(frame: frame)
        
        floatingActionButton.animateStyle = style
        floatingActionButton.dataSource = self
        floatingActionButton.delegate = self
        
        return floatingActionButton
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .Default
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return episodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Episode Cell", forIndexPath: indexPath) as! EpisodeTableViewCell
        let episode = self.episodes[indexPath.row]
        cell.episode = episode
        
        return cell
    }
    
    
    
    
}

//
//extension EpisodesViewController : SFSafariViewControllerDelegate
//{
//    func safariViewControllerDidFinish(controller: SFSafariViewController)
//    {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
//}

extension EpisodesViewController: LiquidFloatingActionButtonDataSource
{
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int
    {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell
    {
        return cells[index]
    }
}

extension EpisodesViewController: LiquidFloatingActionButtonDelegate
{
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int)
    {
        // create playlist from another playlist
        if index == 0
        {
            self.performSegueWithIdentifier("gotoAddFromPlaylist", sender: self)
            
        }
        // create playlist from artist's tracks
        else if index == 1
        {
             self.performSegueWithIdentifier("gotoAddFromArtist", sender: self)
            
        }
        
        self.floatingActionButton.close()
    }
}

//extension EpisodesViewController: UITableViewDataSource
//{
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return episodes.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("Episode Cell", forIndexPath: indexPath) as! EpisodeTableViewCell
//        let episode = self.episodes[indexPath.row]
//        cell.episode = episode
//        
//        return cell
//    }
//}

//extension EpisodesViewController: UITableViewDelegate
//{
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
//    {
//        
//        episodes.targetWillDisplayEntry(indexPath.row)
//    }
//    
//}





