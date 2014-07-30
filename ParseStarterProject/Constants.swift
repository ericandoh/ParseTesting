//
//  Constants.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/26/14.
//
//

import Foundation

//----------------------------Loading Constants---------------------------------

//preface all descriptions with a comment describing what the constant acts as
let SAMPLE_CONSTANT = 0

//debug flag, turn to true to turn on debug statements
//mostly unused as of now
let N_DEBUG_FLAG = true //currently not used, there is a separate DEBUG_FLAG in the starting app delegate

//maximum num of notifications that should remain buffered (exception being unread notifications)
let NOTIF_COUNT = 10

//number of post-images to load at once
//more posts to load = slower start time, faster flip time consistency
//less posts to load = faster start time, increased inconsistency in page loads
let POST_LOAD_COUNT = 10

//number of posts to have before buffering next set of images
let POST_LOAD_LIMIT = 20

//maximum number of my own posts to load (when i query for my last submitted posts)
//no post load limit count - buffer as I read collectionView
let MYPOST_LOAD_COUNT = 15

//maximum number of search results to load at once
let SEARCH_LOAD_COUNT = 20;

//number of comments to load at once
//we will NOT use this constant: usually less than <100 comments at a time, if we had more we would have to load in chunks
//but for small # of comments we can just load all into one array and be ok with that (plus its text, unlike notifs/image posts)
//let MYCOMMENT_LOAD_COUNT = 20

//----------------------------Image Constants---------------------------------

//Whenever something needs to be loaded, this picture shows up
let LOADING_IMG: UIImage = UIImage(named: "horned-logo.png");

//When HomeFeed is done with pictures, this picture is shown
let ENDING_IMG: UIImage = UIImage(named: "daniel-craig.jpg");

//camera icon image in upload flow
let CAMERA_ICON = UIImage(named: "temp_camera_icon.jpg")

//default images
let DEFAULT_USER_ICON = UIImage(named: "unknown_user.png");

//----------------------------Width/Height Constants---------------------------------

//width of a fullscreen image
let FULLSCREEN_WIDTH = 320;

//height of a fullscreen image
let FULLSCREEN_HEIGHT = 518;

//when clicking on edit posts, point of contact must be this much below picture to trigger swipe delete
let UPLOAD_TABLE_DELETE_LIMIT = 100.0;

//how dim the right side of the menu becomes when side menu (left) is triggered and pulled out
//you can change hue in storyboard
let SIDE_MENU_DIM = 0.5;

//ratio of width to height
let WIDTH_HEIGHT_RATIO = Float(FULLSCREEN_WIDTH) / Float(FULLSCREEN_HEIGHT);

//max size of an image
let MAX_IMAGE_SIZE = FULLSCREEN_WIDTH * FULLSCREEN_HEIGHT;

//side menu bar width
let BAR_WIDTH = 225.0;

//from where swiping left triggers side menu bar
let TRIGGER_BAR_WIDTH = 200.0;

//numbers for shop the look boxes in upload flow
let BOX_START_Y = 436.0;                //starting y pos of shop look boxes
let LABEL_BOX_HEIGHT = 40.0;            //individual box heights
let LABEL_SPACING = 5.0;                //spacing between each box
let BOX_INCR_Y = LABEL_BOX_HEIGHT + LABEL_SPACING;
let BOX_WIDTH = 300.0;                  //width of box
let BOX_LEFT_MARGIN = (Double(FULLSCREEN_WIDTH) - BOX_WIDTH) / 2.0
let SCROLLFIELD_DEFAULT_HEIGHT = 595.0; //height of scrollfield when no shoplooks
//----end shop the look------

//----------------------------Side Bar Constants---------------------------------

//side menu bar items we will have
//this references ONLY storyboard ID names
let SIDE_MENU_ITEMS = ["Home", "Search", "Profile", "Notifications", "FindFriends", "Upload"];

//location of the upload variable in SIDE_MENU_ITEMS, modify if we change "Upload" storyboard name
let INDEX_OF_UPLOAD: Int = find(SIDE_MENU_ITEMS, "Upload")!;

//side menu bar items we will have
//this references ONLY the actual names to display on the side menu table
//let SIDE_MENU_NAMES = ["My Stash", "Upload", "Notifications", "Search", "My Profile"];
let SIDE_MENU_NAMES = ["Home", "Explore", "Profile", "Notifications", "Find People", "Upload"];

//side menu bar images we will have
let SIDE_MENU_IMAGES = [LOADING_IMG, LOADING_IMG, ENDING_IMG, LOADING_IMG, LOADING_IMG, LOADING_IMG];

//----------------------------Type Constants---------------------------------

//String enums to describe type of notification (work need)
enum NotificationType: String {
    case PLAIN_TEXT = "PlainText"
    //case FRIEND_REQUEST = "FriendRequest"
    case FRIEND_ACCEPT = "FriendAccept"
    case IMAGE_POST = "ImagePost"
    case FOLLOWER_NOTIF = "FollowerNotif"
}

//String enums to describe exclusivity of user post (work need)
//this enum is deprecated!
enum PostExclusivity: String {
    case FRIENDS_ONLY = "friends"
    case EVERYONE = "everyone"
    case MALE_ONLY = "male"
    case FEMALE_ONLY = "female"
}
//enum.toRaw() for raw value

//other default images below this line
