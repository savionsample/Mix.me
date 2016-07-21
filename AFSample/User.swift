//
//  User.swift
//  Mix.me
//
//  Created by Savion Sample on 7/20/16.
//  Copyright © 2016 StereoLabs. All rights reserved.
//

import Foundation

class User {
    var accToken = ""
    dynamic var refreshToken = ""
    
    
    func setAccToken(access: String) {
        accToken = access
    }
    
    func setRefreshToken(refresh: String) {
        refreshToken = refresh
    }
    
    func getAccToken() -> String {
        return accToken
    }
    
    
}