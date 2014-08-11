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
let POST_LOAD_COUNT = 15    //used to be 10

//number of posts to have before buffering next set of images
let POST_LOAD_LIMIT = 20

//maximum number of my own posts to load (when i query for my last submitted posts)
//no post load limit count - buffer as I read collectionView
//let MYPOST_LOAD_COUNT = 15

//maximum number of search results to load at once
let SEARCH_LOAD_COUNT = 20;

//how many cells I should have before it starts rendering more
let CELLS_BEFORE_RELOAD = 9;

//number of comments to load at once
//we will NOT use this constant: usually less than <100 comments at a time, if we had more we would have to load in chunks
//but for small # of comments we can just load all into one array and be ok with that (plus its text, unlike notifs/image posts)
//let MYCOMMENT_LOAD_COUNT = 20

//----------------------------Image Constants---------------------------------

let NULL_IMG: UIImage = UIImage(named: "horned-logo.png");

//Whenever something needs to be loaded, this picture shows up
let LOADING_IMG: UIImage = UIImage(named: "horned-logo.png");

//When HomeFeed is done with pictures, this picture is shown
let ENDING_IMG: UIImage = UIImage(named: "daniel-craig.jpg");

//camera icon image in upload flow
let CAMERA_ICON = UIImage(named: "f_camera_roll.png")

//default images
let DEFAULT_USER_ICON = UIImage(named: "unknown_user.png");

//close button image for Shop The Look while uploading
let CLOSE_SHOP_EDIT_ICON = UIImage(named: "horned-logo.png");

let NORMAL_HEART = UIImage(named: "heart.png")

let GRADIENT_IMG = UIImage(named: "gradient.png")

let LIKED_HEART = UIImage(named: "horned-logo.png");

//icon of a person and a plus, indicating that if pressed I can start following this person
let FOLLOW_ME_ICON: UIImage = UIImage(named: "follow.png");

//icon of a person and a check, indicating that I am already following this person. Clicking on this triggers a notification asking if I want to unfollow this person
let FOLLOWED_ME_ICON: UIImage = UIImage(named: "followed.png");

//icon in home that takes you to info page right away
let INFO_ICON = UIImage(named: "info.png");

//----------------------------Width/Height Constants---------------------------------

//width of a fullscreen image
let FULLSCREEN_WIDTH: CGFloat = CGFloat(320);

//height of a fullscreen image
let FULLSCREEN_HEIGHT: CGFloat = CGFloat(518);

//height of a fullscreen app
let TRUE_FULLSCREEN_HEIGHT = CGFloat(568);

//when clicking on edit posts, point of contact must be this much below picture to trigger swipe delete
let UPLOAD_TABLE_DELETE_LIMIT = CGFloat(100.0);

//how dim the right side of the menu becomes when side menu (left) is triggered and pulled out
//you can change hue in storyboard
let SIDE_MENU_DIM = CGFloat(0.5);

//ratio of width to height
let WIDTH_HEIGHT_RATIO = CGFloat(FULLSCREEN_WIDTH) / CGFloat(FULLSCREEN_HEIGHT);

//max size of an image
let MAX_IMAGE_SIZE = FULLSCREEN_WIDTH * FULLSCREEN_HEIGHT;

//side menu bar width
let BAR_WIDTH = CGFloat(225.0);

//from where swiping left triggers side menu bar
let TRIGGER_BAR_WIDTH = CGFloat(200.0);


//constants for the rotated table in upload flow
let SIDE_MARGINS = CGFloat(2.0);
let PREVIEW_CELL_WIDTH: CGFloat = CGFloat(150.0);
let PREVIEW_CELL_HEIGHT: CGFloat = CGFloat(90.0) - SIDE_MARGINS*2;
//----end rotated table-----

//numbers for shop the look boxes in upload flow
let BOX_START_Y = CGFloat(420.0);                //starting y pos of shop look boxes
let LABEL_BUTTON_HEIGHT = CGFloat(20.0);            //individual box heights
let LABEL_SPACING = CGFloat(5.0);                //spacing between each box
let LABEL_BOX_HEIGHT = LABEL_BUTTON_HEIGHT + 2 * LABEL_SPACING;
let BOX_WIDTH = CGFloat(280.0);                  //width of box
let BOX_X = CGFloat(20.0);
let BOX_X_ONE = CGFloat(0.0);             //x coord of box #1 relative to me
let BOX_WIDTH_ONE = CGFloat(240.0);
let BOX_X_TWO = BOX_WIDTH_ONE + CGFloat(10.0);  //x coord box #2 relative to me
let BOX_WIDTH_TWO = CGFloat(20);
let SCROLLFIELD_DEFAULT_HEIGHT = CGFloat(605.0); //height of scrollfield when no shoplooks
//----end shop the look------

//text view attributes for the textview with a placeholder in upload flow
let PREVIEW_TEXT_VIEW_COLOR = UIColor.whiteColor();
let PLACEHOLDER_COLOR = UIColor(white: 1, alpha: 0.32);
let PREVIEW_DESCRIP_PLACEHOLDER_TEXT = "Tell us about your style";

//----------------------------Side Bar Constants---------------------------------

//side menu bar items we will have
//this references ONLY storyboard ID names
let SIDE_MENU_ITEMS = ["HomeNav", "Search", "Profile", "Notifications", "FindFriends", "Upload"];

//location of the upload variable in SIDE_MENU_ITEMS, modify if we change "Upload" storyboard name
let INDEX_OF_UPLOAD: Int = find(SIDE_MENU_ITEMS, "Upload")!;

//side menu bar items we will have
//this references ONLY the actual names to display on the side menu table
//let SIDE_MENU_NAMES = ["My Stash", "Upload", "Notifications", "Search", "My Profile"];
let SIDE_MENU_NAMES = ["Home", "Explore", "Profile", "Notifications", "Find People", "Upload"];

//side menu bar images we will have
let SIDE_MENU_IMAGES = [LOADING_IMG, LOADING_IMG, ENDING_IMG, LOADING_IMG, LOADING_IMG, LOADING_IMG];

//side menu bar item opacities
let SIDE_MENU_OPACITIES = [1.0, 0.75, 0.57, 0.37, 0.25, 0.1];

//----------------------------Type Constants---------------------------------

//String enums to describe type of notification (work need)
enum NotificationType: String {
    case PLAIN_TEXT = "PlainText"
    //case FRIEND_REQUEST = "FriendRequest"
    case FRIEND_ACCEPT = "FriendAccept"
    case IMAGE_POST = "ImagePost"
    case FOLLOWER_NOTIF = "FollowerNotif"
}

//Int enums to describe direction (of swipe, for home feed)
enum CompassDirection: Int {
    case STAY = 0;
    case NORTH = 1;
    case EAST = 2;
    case SOUTH = 3;
    case WEST = 4;
}

//String enums to describe exclusivity of user post (work need)
//this enum is deprecated!
enum PostExclusivity: String {
    case FRIENDS_ONLY = "friends"
    case EVERYONE = "everyone"
    case MALE_ONLY = "male"
    case FEMALE_ONLY = "female"
}

enum UserType: String {
    case DEFAULT = "default"
    case FACEBOOK = "facebook"
    case ANON = "anon"
}

var RELEVANT_TYPES = [UserType.DEFAULT.toRaw(), UserType.FACEBOOK.toRaw()];

//enum.toRaw() for raw value

//other default images below this line
