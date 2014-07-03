//
//  FriendEncapsulator.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/2/14.
//
//

//made solely for FriendTableViewController pretty much (so far) and SettingsVC (which is basically a user profile right now?)
class FriendEncapsulator {
    var friendObj: PFUser
    var username: String = "";
    var friendImg: UIImage? = nil;
    init(friend: PFUser) {
        friendObj = friend;
    }
    //gets the name of the user, fetches it if needed
    func getName(failFunction: ()->Void)->String {
        if (friendObj.isDataAvailable()) {
            username = friendObj.username;
        }
        else {
            friendObj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in });
            //controller.tableView.reloadData();
            failFunction();
        }
        return username;
    }
    func fetchImage(receiveAction:(UIImage)->Void) {
        if friendImg {
            receiveAction(friendImg!);
        }
        else {
            return;
            friendObj.fetchIfNeededInBackgroundWithBlock({(object:PFObject!, error: NSError!)->Void in
                NSLog("All the keys")
                for key : AnyObject in object.allKeys() {
                    NSLog("A key is \(key as String)")
                }
                var runCount: Int = object["RunCount"] as Int;
                NSLog("ran this \(runCount) times")
                if (object["userIcon"] == nil) {
                    return;
                }
                //var obj = object["userIcon"] as PFFile;
                var obj = object.objectForKey("userIcon") as PFFile;
                obj.getDataInBackgroundWithBlock({(result: NSData!, error: NSError!) in
                    self.friendImg = UIImage(data: result);
                    //receiveAction(self.friendImg!);
                });
            });
        }
    }
}
