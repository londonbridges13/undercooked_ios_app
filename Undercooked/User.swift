//
//  User.swift
//  Undercooked
//
//  Created by Lyndon Samual McKay on 12/15/16.
//  Copyright © 2016 Lyndon Samual McKay. All rights reserved.
//

import Foundation
import RealmSwift


class User : Object{
    
    dynamic var name : String?
    dynamic var email : String?
    dynamic var password : String?
    dynamic var profile_pic : NSData?
    
    dynamic var access_token : String? // To Access this user's properties
    dynamic var client_token : String? // To Access the server
    
    dynamic var launch_count = 0 // Displays how often user opens app
    dynamic var user_invited = false // Checks if User has invited friends to use Undercooked


}
