//
//  FriendEncapsulator.swift
//  ParseStarterProject
//
//  Class to encapsulate friend in a non-Parse object without subclassing
//  Innately stores username as well
//
//  Created by Eric Oh on 7/2/14.
//
//

var friendDictionary: [String: FriendEncapsulator] = [:];

//made solely for FriendTableViewController pretty much (so far) and SettingsVC (which is basically a user profile right now?)
class FriendEncapsulator {
    var friendObj: PFUser?
    var username: String = "";
    var userID: String = "";
    var friendImg: UIImage? = nil;
    init(friend: PFUser) {
        //run by settings from main
        friendObj = friend;
        if (friendObj!.username != nil) {
            username = friendObj!.username
        } else {
            username = "Anonymous"
        }
        userID = friendObj!.objectId;
    }
    init(friendName: String) {
        //run by everythign else
        username = friendName;
        friendObj = nil;
        NSLog("Deprecated method - friendenc by username");
    }
    init(friendID: String) {
        //run by everythign else
        userID = friendID
        var qry = PFUser.query()
        qry.whereKey("objectId", equalTo: friendID)
        
        qry.getObjectInBackgroundWithId(friendID, block: {
            (result: PFObject!, err: NSError!) in
            self.friendObj = result as PFUser?
            if ((self.friendObj) != nil) {
                self.username = self.friendObj!.username
            } else {
                self.username = "Anonymous" // TODO: empty or anonymous user?
            }
        })
    }
    class func dequeueFriendEncapsulator(friend: PFUser)->FriendEncapsulator {
        if (PFAnonymousUtils.isLinkedWithUser(friend)) {
            var newFriendToMake = FriendEncapsulator(friend: friend);
            return newFriendToMake;
        }
        var friendExist: FriendEncapsulator? = friendDictionary[friend.objectId];
        if (friendExist != nil) {
            if (friendExist!.friendObj == nil) {
                friendExist!.friendObj = friend;
            }
            return friendExist!;
        }
        else {
            var newFriendToMake = FriendEncapsulator(friend: friend);
            friendDictionary[friend.objectId] = newFriendToMake;
            return newFriendToMake;
        }
    }
    
    class func dequeueFriendEncapsulatorWithID(friendID: String)->FriendEncapsulator {
        var friendExist: FriendEncapsulator? = friendDictionary[friendID];
        if (friendExist != nil) {
            return friendExist!;
        }
        else {
            //query to check that this id does exist - exist???
            var newFriendToMake = FriendEncapsulator(friendID: friendID);
            friendDictionary[friendID] = newFriendToMake;
            return newFriendToMake;
        }
    }
    
    class func dequeueFriendEncapsulator(friendName: String)->FriendEncapsulator {
        NSLog("Deprecated method - friendenc dequeue by username");
        var friendExist: FriendEncapsulator? = friendDictionary[friendName];
        if (friendExist != nil) {
            return friendExist!;
        }
        else {
            var newFriendToMake = FriendEncapsulator(friendName: friendName);
            friendDictionary[friendName] = newFriendToMake;
            return newFriendToMake;
        }
    }
    
    class func dequeueFriendEncapsulatorByName(name: String, finishFunction: (FriendEncapsulator?)->Void) {
        //do query by name for a friend
        //if its in dictionary return it
        //else query for it by name, and then save it into dictionary if relevant
        
        var qry = PFUser.query()
        qry.whereKey("username", equalTo: name)
        
        qry.getFirstObjectInBackgroundWithBlock({
            (result: PFObject!, err: NSError!) in
            if (result != nil) {
                let friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(result!.objectId)
                finishFunction(friend)
            }
            else {
                finishFunction(nil)
            }
        })
    }
    
    class func waitTill(id: String, endFunction: ()->Void) {
        let friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(id)
        if (friend.friendObj == nil) {
            var qry = PFUser.query()
            qry.getObjectInBackgroundWithId(id, block: {
                (result: PFObject!, err: NSError!) in
                friend.friendObj = result as PFUser?
                if ((friend.friendObj) != nil) {
                    friend.username = friend.friendObj!.username
                } else {
                    friend.username = "Anonymous" // TODO: empty or anonymous user?
                }
                endFunction()
            })
        }
        else {
            endFunction()
        }
    }
    
    //will call endFunction once all items with ID have their PFObject loaded in
    class func waitTillAll(idList: Array<String>, endFunction: ()->Void) {
        var loaded = 0
        for index in 0..<idList.count {
            let friend = FriendEncapsulator.dequeueFriendEncapsulatorWithID(idList[index])
            if (friend.friendObj == nil) {
                var qry = PFUser.query()
                qry.getObjectInBackgroundWithId(idList[index], block: {
                    (result: PFObject!, err: NSError!) in
                    friend.friendObj = result as PFUser?
                    if ((friend.friendObj) != nil) {
                        friend.username = friend.friendObj!.username
                    } else {
                        friend.username = "Anonymous" // TODO: empty or anonymous user?
                    }
                    loaded += 1
                    if (loaded == idList.count) {
                        endFunction()
                    }
                })
            }
            else {
                loaded += 1
                if (loaded == idList.count) {
                    endFunction()
                }
            }
        }
    }
    
    func getID()->String {
        return userID;
    }
    
    //gets the name of the user, fetches it if needed
    func getName(failFunction: ()->Void)->String {
        if (username != "") {
            return username;
        }
        if (friendObj != nil) {
            if (friendObj!.isDataAvailable()) {
                username = friendObj!.username;
            }
            else {
                friendObj!.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in });
                //controller.tableView.reloadData();
                failFunction();
            }
        }
        return username;
    }
    func getNameWithExtras(retFunc: (String)->Void) {
        if (friendObj == nil) {
            var query = PFUser.query();
            query.whereKey("username", equalTo: self.username);
            query.limit = 1;
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if (error == nil && objects.count > 0)  {
                    self.friendObj = objects[0] as? PFUser;
                    self.getNameWithExtras(retFunc);
                }
                else if (error != nil) {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo!)
                }
                else if (objects.count == 0) {
                    NSLog("Can't find user: \(self.username)")
                    retFunc(self.username);
                }
            }
        }
        else {
            if (friendObj!["personFirstName"] != nil) {
                var fName = friendObj!["personFirstName"] as String;
                retFunc(username + "\n" + fName);
            }
            else {
                if (friendObj!["email"] != nil) {
                    var pEmail = friendObj!["email"] as String;
                    retFunc(username + "\n" + pEmail);
                }
                else {
                    retFunc(username);
                }
            }
        }
    }
    
    func getNumLiked() -> Int {
        if (friendObj == nil) {
            return 0
        }
        var numLiked: Int = friendObj!["likedPosts"].count
        return numLiked
    }
    
    func getNumPosts(completionHandler: (Int?, NSError?) -> Void) {
        var query = PFQuery(className: "ImagePost")
        query.whereKey("authorId", equalTo: friendObj!.objectId)
        query.countObjectsInBackgroundWithBlock{(count: Int32, error: NSError!)->Void in
            if error == nil {
                completionHandler(Int(count), nil)
            } else {
                NSLog("Error when getting post number %@", error.description)
                completionHandler(nil, error)
            }
        }
    }
    
    
    func exists(result: (Bool)->Void) {
        var query = PFUser.query();
        query.whereKey("objectId", equalTo: userID);
        query.limit = 1;
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil && objects.count > 0)  {
                result(true);
            }
            else if (error != nil) {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
                result(false);
            }
            else if (objects.count == 0) {
                //NSLog("Can't find user: \(self.username)")
                result(false);
            }
        }

    }
    func fetchImage(receiveAction:(UIImage)->Void) {
        if (friendImg != nil) {
            receiveAction(friendImg!);
        }
        else if (friendObj != nil) {
            //fetch friend + get image
            if (friendObj!["userIcon"] == nil) {
                receiveAction(DEFAULT_USER_ICON);
                return;
            }
            var obj = friendObj!["userIcon"] as PFFile;
            obj.getDataInBackgroundWithBlock({(result: NSData!, error: NSError!) in
                if (error == nil) {
                    self.friendImg = UIImage(data: result);
                    receiveAction(self.friendImg!);
                }
                else {
                    NSLog("Error: %@ %@", error, error.userInfo!)
                    receiveAction(DEFAULT_USER_ICON);
                }
            });
        }
        else {
            var qry = PFUser.query()
            qry.whereKey("objectId", equalTo: self.userID)
            qry.getObjectInBackgroundWithId(self.userID, block: {
                (result: PFObject!, err: NSError!) in
                self.friendObj = result as PFUser?
                if ((self.friendObj) != nil) {
                    self.username = self.friendObj!.username
                    self.fetchImage(receiveAction)
                } else {
                    self.username = "Anonymous" // TODO: empty or anonymous user?
                }
            })
        }
    }
    
    func getWebURL(completionHandler: String? -> Void) {
        var query = PFUser.query()
        query.whereKey("objectId", equalTo: userID)
        query.getFirstObjectInBackgroundWithBlock{(user: AnyObject!, error: NSError!)->Void in
            if error == nil {
                let userObj = user as PFUser
                completionHandler(userObj["webURL"] as? String)
            } else {
                NSLog("Error when getting user web url %@", error.description)
                completionHandler(nil)
            }
        }
    }
    
    func isFanPageUser(completionHandler: String? -> Void) {
        var query = PFUser.query()
        query.whereKey("objectId", equalTo: userID)
        query.getFirstObjectInBackgroundWithBlock{(user: AnyObject!, error: NSError!)->Void in
            if error == nil {
                let userObj = user as PFUser
                completionHandler(userObj["fanPageUser"] as? String)
            } else {
                NSLog("Error when getting fan page user %@", error.description)
                completionHandler(nil)
            }
        }
    }
}
