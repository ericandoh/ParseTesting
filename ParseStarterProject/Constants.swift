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

//number of posts to have before buffering next set of images
let POST_LOAD_LIMIT = 20

//maximum number of my own posts to load (when i query for my last submitted posts)
let MYPOST_LOAD_COUNT = 10

//maximum number of search results to load at once
let SEARCH_LOAD_COUNT = 20;

//Whenever something needs to be loaded, this picture shows up
let LOADING_IMG: UIImage = UIImage(named: "horned-logo.png");

//When HomeFeed is done with pictures, this picture is shown
let ENDING_IMG: UIImage = UIImage(named: "daniel-craig.jpg");

//width of a fullscreen image
let FULLSCREEN_WIDTH = 320;

//height of a fullscreen image
let FULLSCREEN_HEIGHT = 518;

//ratio of width to height
let WIDTH_HEIGHT_RATIO = Float(FULLSCREEN_WIDTH) / Float(FULLSCREEN_HEIGHT);

//max size of an image
let MAX_IMAGE_SIZE = FULLSCREEN_WIDTH * FULLSCREEN_HEIGHT;

//side menu bar items we will have
//this references BOTH names to be shown + storyboard ID names
let SIDE_MENU_ITEMS = ["Home", "Upload", "Notifications", "Search", "Profile"];

//side menu bar width
let BAR_WIDTH = 160.0;


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
