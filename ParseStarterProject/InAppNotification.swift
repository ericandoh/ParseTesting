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
    var messageString: String = "";
    var friendName: String = "";
    var type: String = NotificationType.PLAIN_TEXT.toRaw();
    var personalObj: PFObject? = nil
    init(message: String) {
        //makes a default notification with just a text string
        messageString = message;
        type = NotificationType.PLAIN_TEXT.toRaw();
    }
    init(dataObject: PFObject) {
        personalObj = dataObject
    }
    init(dataObject: PFObject, message: String) {
        messageString = message;
        personalObj = dataObject
    }
    func assignMessage(listener: NotifViewController) {
        //fetch notification message as necessary
        if (personalObj != nil) {
            
            //I actually shouldn't need to fetch my personalObj, should already be loaded in from query
            //this is outdated code from when I had another database schema
            
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
                case NotificationType.FRIEND_REQUEST.toRaw():
                    self.friendName = self.personalObj!["sender"] as String
                    self.messageString = "You have received a friend request from \(self.friendName).";
                    listener.tableView.reloadData();
                    /*var obj = self.personalObj!["sender"] as PFUser
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        self.friendName = object["username"] as String;
                        self.messageString = "You have received a friend request from \(self.friendName).";
                        listener.tableView.reloadData();
                    });*/
                case NotificationType.FRIEND_ACCEPT.toRaw():
                    self.friendName = self.personalObj!["sender"] as String
                    self.messageString = "\(self.friendName) has accepted your friend invitation! People love you now!"
                    listener.tableView.reloadData();
                    /*var obj = self.personalObj!["sender"] as PFUser
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        self.friendName = object["username"] as String
                        self.messageString = "\(self.friendName) has accepted your friend invitation! People love you now!"
                        listener.tableView.reloadData()
                    });*/
                default:
                    self.messageString = self.personalObj!["message"] as String
                    listener.tableView.reloadData()
                }
            });
        }
        else {
            //just use default message String?
            listener.tableView.reloadData();
        }
    }
    func getImage(receiveAction:(UIImage)->Void) {
        if (type != NotificationType.IMAGE_POST.toRaw()) {
            //Post does not have image associated with it
            NSLog("Cannot retrieve image from non-image post notification")
        }
        var obj = self.personalObj!["ImagePost"] as PFObject
        obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
            var imgFile: PFFile = object["imageFile"] as PFFile;
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                //get file objects
                receiveAction(UIImage(data: result));
            });
        });
    }
    
    func getComments(receiveAction:(Array<String>)->Void) {
        var obj = self.personalObj!["ImagePost"] as PFObject
        obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
            var commenting: Array<String> = object["comments"] as Array<String>
            receiveAction(commenting);
        });
    }
    
    func acceptFriend() {
        //for accept notification objects
        if (type != NotificationType.FRIEND_REQUEST.toRaw()) {
            //Post should be a Friend Request Notification
            NSLog("Cannot accept friend from a non-friend request notification!")
        }
        self.friendName = self.personalObj!["sender"] as String;
        ServerInteractor.addAsFriend(self.friendName)
        ServerInteractor.postFriendAccept(self.friendName)
    }
}