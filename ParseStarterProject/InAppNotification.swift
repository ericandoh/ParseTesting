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
    var type: String = NotificationType.PLAIN_TEXT.toRaw();   //I should *probably* use enums for this
    var personalObj: PFObject? = nil
    init(message: String) {
        messageString = message;
        type = NotificationType.PLAIN_TEXT.toRaw();
    }
    init(dataObject: PFObject) {
        //type = dataObject["type"] as String;
        personalObj = dataObject
        //assignMessage(listener);
    }
    init(dataObject: PFObject, message: String) {
        //type = dataObject["type"] as String;
        messageString = message;
        personalObj = dataObject
        //assignMessage(listener);
    }
    func assignMessage(listener: NotifViewController) {
        if (personalObj != nil) {
            personalObj!.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                
                if(object == nil) {
                    NSLog("Something is wrong");
                    return;
                }
                
                self.type = self.personalObj!["type"] as String;
                
                switch self.type {
                case NotificationType.IMAGE_POST.toRaw():
                    var obj = self.personalObj!["ImagePost"] as PFObject
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        var numLikes: Int = object["likes"] as Int
                        self.messageString = "Your picture has gotten \(numLikes) likes!"
                        listener.tableView.reloadData()
                    });
                    //wont we need to fetch it?
                case NotificationType.FRIEND_REQUEST.toRaw():
                    var obj = self.personalObj!["sender"] as PFUser
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        var friendName: String = object["username"] as String
                        self.messageString = "You have received a friend request from \(friendName)."
                        listener.tableView.reloadData()
                    });
                case NotificationType.FRIEND_ACCEPT.toRaw():
                    var obj = self.personalObj!["sender"] as PFUser
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        var friendName: String = object["username"] as String
                        self.messageString = "\(friendName) has accepted your friend invitation! People love you now!"
                        listener.tableView.reloadData()
                    });
                default:
                    self.messageString = self.personalObj!["message"] as String
                    listener.tableView.reloadData()
                }
                //NSLog("Assigned message string \(self.messageString)")
                });
        }
    }
    func interact() {
        //what happens when the user clicks the notification message?
    }
}