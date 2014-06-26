//
//  InAppNotification.swift
//  ParseStarterProject
//
//  A class representing a notification object
//
//  Created by Eric Oh on 6/26/14.
//
//

import Foundation

//probably better written off as a struct, but need to override PFObject => justify using it as an object

class InAppNotification {
    //empty class
    var messageString: String = "";
    
    init(message: String) {
        messageString = message;
    }
}