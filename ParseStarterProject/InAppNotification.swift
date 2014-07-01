//
//  InAppNotification.swift
//  ParseStarterProject
//
//  A class representing a notification object
//
//  Kinds of notifications:
//  1. Plaintext ("Welcome to our app!")
//  2. Friend notifications ("__ wants to add you? Accept?") ("___ accepted your friend inv")
//  3. Post notifications ("____ liked your photo!")
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
    init(dataObject: PFObject) {
        //type = dataObject["type"] as String;
        personalObj = dataObject
        //assignMessage(listener);
    }
    func assignMessage(listener: NotifViewController) {
        NSLog("Assigning message");
        if (personalObj != nil) {
            personalObj!.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                NSLog("Fetched")
                
                if(object == nil) {
                    NSLog("Something is wrong");
                    return;
                }
                
                self.type = self.personalObj!["type"] as String;
                
                switch self.type {
                case "ImagePost":
                    var obj = self.personalObj!["ImagePost"] as PFObject
                    //wont we need to fetch it?
                    var numLikes: Int = obj["likes"] as Int
                    self.messageString = "Your picture has gotten \(numLikes) likes!"
                case "FriendRequest":
                    var obj = self.personalObj!["friend"] as PFUser
                    var friendName: String = obj["username"] as String
                    self.messageString = "You have received a friend request from \(friendName)."
                case "FriendAccept":
                    var obj = self.personalObj!["friend"] as PFUser
                    var friendName: String = obj["username"] as String
                    self.messageString = "\(friendName) has accepted your friend invitation! People love you now!"
                default:
                    self.messageString = self.personalObj!["message"] as String
                }
                NSLog("Assigned message string \(self.messageString)")
                listener.tableView.reloadData()
                });
        }
    }
    func interact() {
        //what happens when the user clicks the notification message?
    }
}