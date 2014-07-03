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
}
