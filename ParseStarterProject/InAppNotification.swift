//
//  InAppNotification.swift
//  ParseStarterProject
//
//  A class representing a notification object
//
//  Kinds of notifications:
//  1. Plaintext ("Welcome to our app!")
//  2. Friend notifs ("__ wants to add you? Accept?") ("___ accepted your friend inv")
//  3. Post notifs ("____ liked your photo!")
//
//  Created by Eric Oh on 6/26/14.
//
//

import Foundation

//probably better written off as a struct, but need to encapsulate ImagePostStruct => justify using it as an object

class InAppNotification {
    //empty class
    var messageString: String = "";
    var type: String = "PlainText";   //I should *probably* use enums for this
    var personalObj: PFObject? = nil
    init(message: String) {
        messageString = message;
        type = "PlainText"
    }
    init(dataObject: PFObject?) {
        if let dataPF = dataObject {
            type = dataPF["type"] as String;
            personalObj = dataPF
            assignMessage();
        }
    }
    func assignMessage() {
        switch type {
        case "ImagePost":
            var obj = personalObj!["ImagePost"] as PFObject
            //wont we need to fetch it?
            var numLikes: Int = obj["likes"] as Int
            messageString = "Your picture has gotten \(numLikes) likes!"
        case "FriendRequest":
            var obj = personalObj!["friend"] as PFUser
            var friendName: String = obj["username"] as String
            messageString = "You have received a friend request from \(friendName)."
        case "FriendAccept":
            var obj = personalObj!["friend"] as PFUser
            var friendName: String = obj["username"] as String
            messageString = "\(friendName) has accepted your friend invitation! People love you now!"
        default:
            //this is to keep Xcode from complaining
            messageString = messageString + ""
        }
    }
    func interact() {
        //what happens when the user clicks the notification message?
    }
}