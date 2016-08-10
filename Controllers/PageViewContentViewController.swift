//
//  PageViewContentViewController.swift
//  Mix.me
//
//  Created by Savion Sample on 7/28/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import UIKit

class PageViewContentViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.imageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
