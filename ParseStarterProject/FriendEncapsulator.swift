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
    init(friend: PFUser) {
        friendObj = friend;
    }
    func getName()->String {
        //hopefully stuff is loaded, else I'll load it myself personally here if it errors
        return friendObj.username;
    }
}
