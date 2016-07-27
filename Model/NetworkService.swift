//
//  NetworkService.swift
//  Duc Blog
//
//  Created by Duc Tran on 4/3/16.
//  Copyright © 2016 Developers Academy. All rights reserved.
//

import Foundation

class NetworkService
{
    lazy var configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.configuration)
    
    let url: NSURL
    
    init(url: NSURL) {
        self.url = url
    }
    
    typealias ImageDataHandler = (NSData -> Void)
    
    func downloadImage(completion: ImageDataHandler)
    {
        let request = NSURLRequest(URL: self.url)
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if error == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
                    switch (httpResponse.statusCode) {
                    case 200:
                        if let data = data {
                            completion(data)
                        }
                    default:
                        print(httpResponse.statusCode)
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
        
        dataTask.resume()
    }
}

extension NetworkService
{
    static func parseJSONFromData(jsonData: NSData?) -> [String : AnyObject]?
    {
        if let data = jsonData {
            do {
                let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject]
                return jsonDictionary
            } catch let error as NSError {
                print("Error processing json data: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
}





















