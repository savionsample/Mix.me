//
//  ListNotesTableViewController.swift
//  MakeSchoolNotes
//
//  Created by Chris Orcutt on 1/10/16.
//  Copyright © 2016 MakeSchool. All rights reserved.
//

import UIKit
//
class HomeScreenTableViewController: UITableViewController {


    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("hello")
        if let identifier = segue.identifier {
            if identifier == "gotToLogin" {
                print("Table view cell tapped")
          
                
            } else if identifier == "addNote" {
                print("+ button tapped")
            }
        }
    }
    

    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
}