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
    //gets the name of the user, fetches it if needed
    func getName(failFunction: ()->Void)->String {
        if (username != "") {
            return username;
        }
        if (friendObj) {
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
    func fetchImage(receiveAction:(UIImage)->Void) {
        if friendImg {
            receiveAction(friendImg!);
        }
        else if (friendObj) {
            //fetch friend + get image
            if (friendObj!["userIcon"] == nil) {
                receiveAction(DEFAULT_USER_ICON);
                return;
            }
            var obj = friendObj!["userIcon"] as PFFile;
            obj.getDataInBackgroundWithBlock({(result: NSData!, error: NSError!) in
                self.friendImg = UIImage(data: result);
                receiveAction(self.friendImg!);
            });
        }
        else {
            var query = PFUser.query();
            query.whereKey("username", equalTo: self.username);
            query.limit = 1;
            query.findObjectsInBackgroundWithBlock {
                (objects: AnyObject[]!, error: NSError!) -> Void in
                if (!error && objects.count > 0)  {
                    self.friendObj = objects[0] as? PFUser;
                    self.fetchImage(receiveAction);
                }
                else if (error) {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo)
                }
                else if (objects.count == 0) {
                    NSLog("Can't find user: \(self.username)")
                }
            }
        }
    }
}
