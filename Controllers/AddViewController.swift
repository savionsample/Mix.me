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

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var accToken = ""
    
    

    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var myTimePicker: UIPickerView!
    @IBAction func hideKeyboard(sender: AnyObject) {
        userTextField.resignFirstResponder()
    }
    
    
    @IBAction func hiddenButton(sender: AnyObject) {
        userTextField.resignFirstResponder()
    }
    
  
    
    
    @IBAction func playlistButtonPressed(sender: AnyObject) {
        
        let artist = self.userTextField.text!
        
        let replaced = String(artist.characters.map {
            $0 == " " ? "+" : $0
        })
        print(replaced)
        
        
        var artistID = ""
        
        // GET ARTIST'S ID
        Alamofire.request(.GET, "https://api.spotify.com/v1/search?q=\(replaced)&type=artist").validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    artistID = json["artists"]["items"][0]["id"].stringValue

                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        
        ////////////////////////
        
        
        var dictOfEverything = [String : Int]()
        var arrOfNames = [String]()
        var arrOfTimes = [Int]()
        
        Alamofire.request(.GET, "https://api.spotify.com/v1/artists/\(artistID)/top-tracks?country=US").validate().responseJSON { response in
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
    
    var pickerData = ["1 minute", "2 minutes", "2 minutes", "4 minutes", "5 minutes", "6 minutes", "7 minutes", "8 minutes", "9 minutes", "10 minutes", "11 minutes", "12 minutes", "13 minutes", "14 minutes", "15 minutes", "16 minutes", "17 minutes", "18 minutes", "19 minutes", "20 minutes", "21 minutes", "22 minutes", "23 minutes", "24 minutes", "25 minutes", "26 minutes", "27 minutes", "28 minutes", "29 minutes", "30 minutes", "31 minutes", "32 minutes", "33 minutes", "34 minutes", "35 minutes", "36 minutes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myTimePicker.delegate = self
        self.myTimePicker.dataSource = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        accToken = appDelegate.getAccessToken()
        
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
        print(pickerData[row])
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


}
