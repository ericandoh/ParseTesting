//
//  Constants.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/26/14.
//
//

import Foundation


//add description of constant
let SAMPLE_CONSTANT = 0

//debug on or off?
let N_DEBUG_FLAG = true //currently not used, there is a separate DEBUG_FLAG in the starting app delegate

//maximum num of notifs that show up
let NOTIF_COUNT = 10

//number of post-images to load at once
let POST_LOAD_COUNT = 10

//maximum number of my own posts to load (when i query for my last submitted posts)
let MYPOST_LOAD_COUNT = 20

//number of comments to load at once
//we will NOT use this constant: usually less than <100 comments at a time, if we had more we would have to load in chunks
//but for small # of comments we can just load all into one array and be ok with that (plus its text, unlike notifs/image posts)
//let MYCOMMENT_LOAD_COUNT = 20

//String enums to describe type of notification (work need)
enum NotificationType: String {
    case PLAIN_TEXT = "PlainText"
    case FRIEND_REQUEST = "FriendRequest"
    case FRIEND_ACCEPT = "FriendAccept"
    case IMAGE_POST = "ImagePost"
}

//String enums to describe exclusivity of user post (work need)
enum PostExclusivity: String {
    case FRIENDS_ONLY = "friends"
    case EVERYONE = "everyone"
    case MALE_ONLY = "male"
    case FEMALE_ONLY = "female"
}
//enum.toRaw() for raw value

//default images
let DEFAULT_USER_ICON = UIImage(named: "unknown_user.png");

//other default images below this line
