//
//  PlaylistsViewController
//  Mix.me
//
//  Created by Savion Sample on 7/19/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit
import LiquidFloatingActionButton

class PlaylistsViewController: UIViewController
{
    var count = 0
    var playlists = [Playlist]()
    var cells = [LiquidFloatingCell]() // data source
    var floatingActionButton: LiquidFloatingActionButton!

    @IBOutlet weak var spinner: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        self.navigationController!.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 100.0)
        
        createFloatingButton()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        let pl = Playlist(title: "",description: "",thumbnailURL: NSURL(fileURLWithPath: "a"),createdAt: "",author: "")
        
        pl.getAccToken()
        pl.getUserID()
        
        Playlist.downloadAllPlaylists(pl.returnAccToken(), id: pl.returnID()) { (playlists: [Playlist]) in
            self.playlists = playlists
            self.tableView.reloadData()
            self.tableView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        }
        
    }
    
    @IBAction func reloadButton(sender: AnyObject)
    {
        self.spinner.rotate360Degrees()

        let pl = Playlist(title: "",description: "",thumbnailURL: NSURL(fileURLWithPath: "a"),createdAt: "",author: "")
        
        pl.getAccToken()
        pl.getUserID()
        
        Playlist.downloadAllPlaylists(pl.returnAccToken(), id: pl.returnID()) { (playlists: [Playlist]) in
            self.playlists = playlists
            self.tableView.reloadData()

        }
    }
    
    private func createFloatingButton()
    {
        cells.append(createButtonCell("addFromPlaylist"))
        cells.append(createButtonCell("addFromArtist"))
        
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
}

extension PlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return playlists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Episode Cell", forIndexPath: indexPath) as! PlaylistTableViewCell
        let playlist = self.playlists[indexPath.row]
        cell.playlist = playlist
        
        return cell
    }
}

extension PlaylistsViewController: LiquidFloatingActionButtonDataSource
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

extension PlaylistsViewController: LiquidFloatingActionButtonDelegate
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



