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
    var type: String = NotificationType.PLAIN_TEXT.rawValue;
    var personalObj: PFObject? = nil
    var wasRead: Bool = false;
    init(message: String) {
        //makes a default notification with just a text string
        messageString = message;
        type = NotificationType.PLAIN_TEXT.rawValue;
    }
    init(dataObject: PFObject, wasRead: Bool) {
        personalObj = dataObject
        self.wasRead = wasRead;
    }
    /*init(dataObject: PFObject, message: String) {
        messageString = message;
        personalObj = dataObject
    }*/
    func getPushMessage()->String {
        //this assumes the object is already fetched (since we just made it!)
        //or should it not? (if we're bumping one
        
        self.type = self.personalObj!["type"] as String;
        
        var msgToSend: String = "Message";
        var fromWho: String = self.personalObj!["sender"] as String
        
        switch self.type {
        case "ImagePost":
            msgToSend = "Your picture has been posted!";
        case NotificationType.IMAGE_POST_LIKE.rawValue:
            msgToSend  = fromWho + " just liked your post!";
        case NotificationType.IMAGE_POST_COMMENT.rawValue:
            msgToSend  = fromWho + " just commented on your post!";
        case NotificationType.FOLLOWER_NOTIF.rawValue:
            msgToSend  = fromWho + " started following you!";
        default:
            msgToSend = self.personalObj!["message"] as String
        }
        return msgToSend
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
                if (error != nil) {
                    NSLog("Error fetching notification message")
                    return;
                }
                
                self.type = self.personalObj!["type"] as String;
                
                switch self.type {
                case "ImagePost":
                    var obj = self.personalObj!["ImagePost"] as PFObject
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        if (error == nil) {
                            var numLikes: Int = object["likes"] as Int
                            //if one person, say "Person" has liked your photo, else "_" people have liked it!
                            self.messageString = "Your picture has been posted!"
                            listener.tableView.reloadData()
                        }
                        else {
                            NSLog("Error fetching image post for notification?");
                        }
                    });
                case NotificationType.IMAGE_POST_LIKE.rawValue:
                    var obj = self.personalObj!["ImagePost"] as PFObject
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        if (error == nil) {
                            var suffix = self.personalObj!["message"] as String
                            var numLikes: Int = object["likes"] as Int
                            if (numLikes <= 1) {
                                var sender = self.getSender().username
                                self.messageString = "@" + sender + suffix;
                            }
                            else {
                                var numString = ServerInteractor.wordNumberer(numLikes);
                                self.messageString = numString + " people" + suffix;
                            }
                            listener.tableView.reloadData()
                        }
                        else {
                            NSLog("Error fetching image post for notification?");
                        }
                    });
                case NotificationType.IMAGE_POST_COMMENT.rawValue:
                    var obj = self.personalObj!["ImagePost"] as PFObject
                    obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                        if (error == nil) {
                            var suffix = self.personalObj!["message"] as String
                            var numComments: Int = (object["comments"] as Array<String>).count
                            var query = PFQuery(className: "PostComment")
                            query.whereKey("postId", equalTo: obj.objectId)
                            query.countObjectsInBackgroundWithBlock{
                                (count: Int32, error: NSError!) -> Void in
                                if error == nil {
                                    numComments = Int(count)
                                }
                            }
                            if (numComments <= 1) {
                                var sender = self.getSender().username
                                self.messageString = "@" + sender + suffix;
                            }
                            else {
                                var numString = ServerInteractor.wordNumberer(numComments);
                                self.messageString = numString + " people" + suffix;
                            }
                            listener.tableView.reloadData()
                        }
                        else {
                            NSLog("Error fetching image post for notification?");
                        }
                    });
                case NotificationType.FOLLOWER_NOTIF.rawValue:
                    self.friendName = self.getSender().username
                    self.messageString = "@\(self.friendName) started following you!";
                    listener.tableView.reloadData();
                    
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
    
    func getSender()->FriendEncapsulator {
        //if (type != NotificationType.FOLLOWER_NOTIF.rawValue) {
            //Post does not have image associated with it
            //NSLog("Cannot retrieve follower from non-follower post notification")
        //}
        var obj: String = self.personalObj!["senderId"] as String
        return FriendEncapsulator.dequeueFriendEncapsulatorWithID(obj);
    }
    
    func getImage(receiveAction:(UIImage)->Void) {
        if (type != NotificationType.IMAGE_POST_LIKE.rawValue && type != NotificationType.IMAGE_POST_COMMENT.rawValue && type != "ImagePost") {
            //Post does not have image associated with it
            NSLog("Cannot retrieve image from non-image post notification")
        }
        //The next line does not really fetch the object just initializes what it should be
        var obj = self.personalObj!["ImagePost"] as PFObject
        //fetchIfNeededInBackgroundWithBlock is used when getting PFObjects (smaller things). This fetches the actual object.
        obj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
            if (error != nil) {
                NSLog("Error fetching notification object image");
                receiveAction(NULL_IMG);
                return;
            }
            var imgFile: PFFile = object["imageFile"] as PFFile;
            //getDataINBackgroundWithBlock is used to get big chunks of data - such as PFFiles
            imgFile.getDataInBackgroundWithBlock( { (result: NSData!, error: NSError!) in
                //get file objects
                if (error != nil) {
                    NSLog("Error fetching notification object image");
                    receiveAction(NULL_IMG);
                    return;
                }
                receiveAction(UIImage(data: result)!);
            });
        });
    }
    
    func getComments(receiveAction:(Array<String>)->Void)->Void {
        NSLog("This looks deprecated; alert me if you see this NSLog -Eric")
        var imgPost = self.personalObj!["ImagePost"] as PFObject
       
        var query = PFQuery(className: "PostComment");
        query.whereKey("postId", equalTo: imgPost.objectId);
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("Error grabbing post comments!");
                return;
            }
            
            if (objects.count > 0) {
                var commenting: Array<String> = [];
                for obj in objects {
                    var pfObj = obj as PFObject;
                    commenting.append(pfObj["content"] as String);
                }
                receiveAction(commenting);
            }
        });
    }
    
    func getImagePost()->PFObject {
        var obj: PFObject = self.personalObj!["ImagePost"] as PFObject
        return obj;
    }
    func wasReadBefore()->Bool {
        return wasRead;
    }
}