//
//  Constants.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/26/14.
//
//

import Foundation

//----------------------------System Constants---------------------------------
let Device = UIDevice.currentDevice()

private let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8

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

//for suggest friends page, how many users to suggest + how many images per each user to preview
let NUM_TO_SUGGEST = 10;
let MAX_IMGS_PER_SUGGEST = 5;

//----------------------------Image Constants---------------------------------

let NULL_IMG: UIImage = UIImage(named: "temporaryloading.png");

//Whenever something needs to be loaded, this picture shows up
let LOADING_IMG: UIImage = UIImage(named: "temporaryloading.png");

//When HomeFeed is done with pictures, this picture is shown
let ENDING_IMG: UIImage = UIImage(named: "daniel-craig.jpg");

//camera icon image in upload flow
let CAMERA_ICON = UIImage(named: "f_camera_roll.png")

//default images
let DEFAULT_USER_ICON = UIImage(named: "unknown_user.png");

//close button image for Shop The Look while uploading
//let CLOSE_SHOP_EDIT_ICON = UIImage(named: "horned-logo.png");

let NORMAL_HEART = UIImage(named: "heart.png")

let LIKED_HEART = UIImage(named: "hearted.png");

let GRADIENT_IMG = UIImage(named: "gradient.png")

//icon of a person and a plus, indicating that if pressed I can start following this person
let FOLLOW_ME_ICON: UIImage = UIImage(named: "follow.png");

//icon of a person and a check, indicating that I am already following this person. Clicking on this triggers a notification asking if I want to unfollow this person
let FOLLOWED_ME_ICON: UIImage = UIImage(named: "followed.png");

//icon in home that takes you to info page right away
let INFO_ICON = UIImage(named: "info.png");

//icon to show back button (for home feed, when seguing from some other screen)
let BACK_ICON = UIImage(named: "arrow_left.png");

//icon to show forward button (referenced in homefeed - shoplook delegate - for shoplook URL forwards)
let FORWARD_ICON = UIImage(named: "arrow_right.png");

let SETTINGS_ICON = UIImage(named: "settings.png");

//side menu images
let HOME_ICON = UIImage(named: "home.png");
let EXPLORE_ICON = UIImage(named: "map.png");
let USER_ICON = UIImage(named: "user.png");
let NOTIF_ICON = UIImage(named: "flag.png");
let FIND_ICON = UIImage(named: "magnifyingglass.png");
let UPLOAD_ICON = UIImage(named: "camera.png");

let CLOSE_SHOP_EDIT_ICON = UIImage(named: "close_button.png");

let TUTORIAL_IMAGE_4 = UIImage(named: "Onboarding_4.png");
let TUTORIAL_IMAGE_5 = UIImage(named: "Onboarding_5S.png");

let NOBODY_HOME_FEED_BACKGROUND = UIImage(named: "FashionStash_Empty.png");

let GREEN_HEX = 0x94eed2;

//163,255,198

let SIDE_MENU_BACK_RED = CGFloat((GREEN_HEX & 0xFF0000) >> 16);
let SIDE_MENU_BACK_GREEN = CGFloat((GREEN_HEX & 0xFF00) >> 8);
let SIDE_MENU_BACK_BLUE = CGFloat((GREEN_HEX & 0xFF));

let SIDE_MENU_BACK_COLOR = UIColor(red: SIDE_MENU_BACK_RED/255.0, green: SIDE_MENU_BACK_GREEN/255.0, blue: SIDE_MENU_BACK_BLUE/255.0, alpha: 1.0);

let TITLE_TEXT_COLOR = UIColor.whiteColor();

let USER_TITLE_TEXT_FONT = UIFont(name: "Didot-HTF-B24-Bold-Ital", size: 16.0);

let TITLE_TEXT_FONT = UIFont(name: "HelveticaNeueLTPro-Lt", size: 20.0);

let TITLE_TEXT_ATTRIBUTES: NSDictionary = [NSForegroundColorAttributeName: TITLE_TEXT_COLOR,
    NSFontAttributeName: TITLE_TEXT_FONT];

let TABLE_CELL_FONT = UIFont(name: "HelveticaNeueLTPro-Lt", size: 15.0)

let FB_PERMISSIONS: [AnyObject]? = ["user_about_me", "user_relationships", "user_friends"];

let SELECTED_COLOR = UIColor(white: 1.0, alpha: 0.9);
let UNSELECTED_COLOR = UIColor(white: 1.0, alpha: 0.4);

//----------------------------Width/Height Constants---------------------------------

//width of a fullscreen image
let FULLSCREEN_WIDTH: CGFloat = UIScreen.mainScreen().bounds.size.width;

//height of a fullscreen app
let TRUE_FULLSCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height;

//width of a fullscreen image
//optimize for 5s, will crop naturally for 4s anyways
//double for retina
let IMGSAVE_FULLSCREEN_WIDTH: CGFloat = CGFloat(640);

//height of a fullscreen image
//optimize for 5s, will crop naturally for 4s anyways
//double for retina
let IMGSAVE_FULLSCREEN_HEIGHT: CGFloat = CGFloat(1136);

//when clicking on edit posts, point of contact must be this much below picture to trigger swipe delete
let UPLOAD_TABLE_DELETE_LIMIT = CGFloat(100.0);

//----consts for constraints in home description-----
let MIN_SHOPLOOK_CONSTRAINT = CGFloat(10.0);
let MIN_DESCRIP_TOTAL_SPACE = TRUE_FULLSCREEN_HEIGHT - 75.0 - 45.0 - 40.0 - 5.0 - 60.0;
//let MIN_SHOPLOOK_DESCRIP_CONSTRAINT = CGFloat(158.0);
let MIN_SHOPLOOK_DESCRIP_CONSTRAINT = ceil(MIN_DESCRIP_TOTAL_SPACE / 2.0);
let MIN_SHOPLOOK_TOTAL_FLEXIBLE_CONSTRAINT = TRUE_FULLSCREEN_HEIGHT - 75.0 - 45.0 - 40.0 - 5.0 - 60.0 - MIN_SHOPLOOK_CONSTRAINT;
//----end home descrip-----

//how dim the right side of the menu becomes when side menu (left) is triggered and pulled out
//you can change hue in storyboard
let SIDE_MENU_DIM = CGFloat(0.05);

let SIDE_MENU_HEADER_HEIGHT = CGFloat(70);

let SIDE_MENU_TABLE_HEIGHT = TRUE_FULLSCREEN_HEIGHT - SIDE_MENU_HEADER_HEIGHT;

//ratio of width to height
let WIDTH_HEIGHT_RATIO = CGFloat(IMGSAVE_FULLSCREEN_WIDTH) / CGFloat(IMGSAVE_FULLSCREEN_HEIGHT);

let THIS_WIDTH_HEIGHT_RATIO = CGFloat(FULLSCREEN_WIDTH) / CGFloat(TRUE_FULLSCREEN_HEIGHT);

//ratio between crop and show
let CROP_WIDTH_HEIGHT_LIMIT_RATIO = CGFloat(1.0);    //width over height

//max size of an image
let MAX_IMAGE_SIZE = FULLSCREEN_WIDTH * TRUE_FULLSCREEN_HEIGHT;

//side menu bar width
let BAR_WIDTH = CGFloat(225.0);

//from where swiping left triggers side menu bar
let TRIGGER_BAR_WIDTH = CGFloat(200.0);

//how much I have to drag down before it triggers
let PULLDOWN_THRESHOLD = CGFloat(200.0);

//constants for user profile name + icon in top nav bar
var TITLE_BAR_WIDTH = CGFloat(220);
var USER_ICON_WIDTH = CGFloat(30);
var TITLE_BAR_HEIGHT = CGFloat(30);
var TITLE_BAR_ICON_TEXT_SPACING = CGFloat(5);


//constants for the rotated table in upload flow
let SIDE_MARGINS = CGFloat(2.0);
let PREVIEW_CELL_WIDTH: CGFloat = CGFloat(150.0);
let PREVIEW_CELL_HEIGHT: CGFloat = CGFloat(90.0) - SIDE_MARGINS*2;
//----end rotated table-----

//numbers for shop the look boxes in upload flow
let BOX_START_Y = CGFloat(440.0);                //starting y pos of shop look boxes
let LABEL_BUTTON_HEIGHT = CGFloat(20.0);            //individual box heights
let LABEL_SPACING = CGFloat(5.0);                //spacing between each box
let LABEL_BOX_HEIGHT = LABEL_BUTTON_HEIGHT + 2 * LABEL_SPACING;
let BOX_WIDTH = CGFloat(280.0);                  //width of box
let BOX_X = CGFloat(20.0);
let BOX_X_ONE = CGFloat(0.0);             //x coord of box #1 relative to me
let BOX_WIDTH_ONE = CGFloat(240.0);
let BOX_X_TWO = BOX_WIDTH_ONE + CGFloat(10.0);  //x coord box #2 relative to me
let BOX_WIDTH_TWO = CGFloat(20);
let SCROLLFIELD_DEFAULT_HEIGHT = CGFloat(625.0); //height of scrollfield when no shoplooks
//----end shop the look------

//text view attributes for the textview with a placeholder in upload flow
let PREVIEW_TEXT_VIEW_COLOR = UIColor.whiteColor();
let PLACEHOLDER_COLOR = UIColor(white: 1, alpha: 0.32);
let PREVIEW_DESCRIP_PLACEHOLDER_TEXT = "Tell us about your style";

//----------------------------Side Bar Constants---------------------------------

//side menu bar items we will have
//this references ONLY storyboard ID names
let SIDE_MENU_ITEMS = ["HomeNav", "Search", "Profile", "Notifications", "FindFriends", "Upload"];

let INDEX_OF_NOTIF: Int = find(SIDE_MENU_ITEMS, "Notifications")!;

//location of the upload variable in SIDE_MENU_ITEMS, modify if we change "Upload" storyboard name
let INDEX_OF_UPLOAD: Int = find(SIDE_MENU_ITEMS, "Upload")!;

let INDEX_OF_HOME: Int = find(SIDE_MENU_ITEMS, "HomeNav")!;

//side menu bar items we will have
//this references ONLY the actual names to display on the side menu table
//let SIDE_MENU_NAMES = ["My Stash", "Upload", "Notifications", "Search", "My Profile"];
let SIDE_MENU_NAMES = ["Home", "Explore", "Profile", "Notifications", "Find Friends", "Upload"];

//side menu bar images we will have
let SIDE_MENU_IMAGES = [HOME_ICON, EXPLORE_ICON, USER_ICON, NOTIF_ICON, FIND_ICON, UPLOAD_ICON];

//side menu bar item opacities
//let SIDE_MENU_OPACITIES = [1.0, 0.75, 0.57, 0.37, 0.25, 0.1];
let SIDE_MENU_OPACITIES = [0.1, 0.25, 0.37, 0.57, 0.75, 1.0];

//how much transparent to make the side menu bar items (1 = very solid, more = more transparent)
let DAMPENING_CONSTANT = CGFloat(2.5);

//side menu individual heights
let SIDE_MENU_TABLE_CELL_HEIGHT = SIDE_MENU_TABLE_HEIGHT / CGFloat(SIDE_MENU_ITEMS.count)

//----------------------------Type Constants---------------------------------

//String enums to describe type of notification (work need)
enum NotificationType: String {
    case PLAIN_TEXT = "PlainText"
    //case FRIEND_REQUEST = "FriendRequest"
    case FRIEND_ACCEPT = "FriendAccept"
    case IMAGE_POST_LIKE = "ImagePostLike"
    case IMAGE_POST_COMMENT = "ImagePostComment"
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

enum SearchUserType: String {
    case BY_NAME = "name"
    case BY_FACEBOOK = "facebook"
    case BY_CONTACTS = "contacts"
}

var RELEVANT_TYPES = [UserType.DEFAULT.toRaw(), UserType.FACEBOOK.toRaw()];

//enum.toRaw() for raw value

//other default images below this line
