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
    var friendImg: UIImage? = nil;
    init(friend: PFUser) {
        //run by settings from main
        friendObj = friend;
        let friend = friendObj!;
        username = friend.username;
    }
    init(friendName: String) {
        //run by everythign else
        username = friendName;
        friendObj = nil;
    }
    
    class func dequeueFriendEncapsulator(friend: PFUser)->FriendEncapsulator {
        if (PFAnonymousUtils.isLinkedWithUser(friend)) {
            var newFriendToMake = FriendEncapsulator(friend: friend);
            return newFriendToMake;
        }
        var friendExist: FriendEncapsulator? = friendDictionary[friend.username];
        if (friendExist != nil) {
            if (friendExist!.friendObj == nil) {
                friendExist!.friendObj = friend;
            }
            return friendExist!;
        }
        else {
            var newFriendToMake = FriendEncapsulator(friend: friend);
            friendDictionary[friend.username] = newFriendToMake;
            return newFriendToMake;
        }
    }
    class func dequeueFriendEncapsulator(friendName: String)->FriendEncapsulator {
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
    
    func getNumLiked() -> Int {
        var numLiked: Int = friendObj!["likedPosts"].count
        return numLiked
    }
    
    func getNumPosts() -> Int {
        var numPosts: Int = friendObj!["numPosts"]! as Int
        return numPosts
    }
    
    
    func exists(result: (Bool)->Void) {
        var query = PFUser.query();
        query.whereKey("username", equalTo: self.username);
        query.limit = 1;
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil && objects.count > 0)  {
                self.friendObj = objects[0] as? PFUser;
                result(true);
            }
            else if (error != nil) {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo)
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
            if (!(friendObj!["userIcon"])) {
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
                    NSLog("Error: %@ %@", error, error.userInfo)
                    receiveAction(DEFAULT_USER_ICON);
                }
            });
        }
        else {
            var query = PFUser.query();
            query.whereKey("username", equalTo: self.username);
            query.limit = 1;
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if (error == nil && objects.count > 0)  {
                    self.friendObj = objects[0] as? PFUser;
                    self.fetchImage(receiveAction);
                }
                else if (error != nil) {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo)
                }
                else if (objects.count == 0) {
                    NSLog("Can't find user: \(self.username)")
                    receiveAction(DEFAULT_USER_ICON);
                }
            }
        }
    }
}
