//
//  UserProfileViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/25/14.
//
//

import Foundation

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var myCollectionView: UICollectionView!
    
    @IBOutlet var numberPosts: UILabel!
    @IBOutlet var numberLikes: UILabel!
    @IBOutlet weak var numberFollowers: UILabel!
    @IBOutlet weak var numberFollowing: UILabel!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    
    
    @IBOutlet weak var AnonText: UILabel!
    @IBOutlet weak var followOthersText: UILabel!
    @IBOutlet weak var haveFollowersText: UILabel!
    
    @IBOutlet weak var SignInAnon: UIButton!
    @IBOutlet var followerTableView: UITableView!
    
    
    @IBOutlet weak var backImageView: BlurringDarkView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet var userInfoView: UIView!
    @IBOutlet var userInfoBackImageView: BlurringDarkView!
    @IBOutlet var userWebURL: UILabel!
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var userIconButton: UIButton!
    @IBOutlet var userInfoBottomBar: UIImageView!
    
    
    var mainUser: FriendEncapsulator?;
    var amMyself: Bool = true
    var friendAction: Bool = false;
    
    /*
    //the posts I have loaded
    var loadedPosts: Array<ImagePostStructure?> = [];
    
    //how many sets I have loaded up to
    var loadedUpTo: Int = 0;
    
    //how many images are loaded in our last set (only valid when hitEnd = true)
    var endLoadCount: Int = 0;
    
    //set to true when I have already loaded in last set of stuff
    var hitEnd: Bool = false;
    
    //isLoading
    var isLoading: Bool = false;
    */
    
    var options: Int = 0;
    
    var collectionDelegatePosts: ImagePostCollectionDelegate?;
    var collectionDelegateLikes: ImagePostCollectionDelegate?;

    var friendList: Array<FriendEncapsulator?> = [];
    
    var alerter: CompatibleAlertViews?;
    
    //var lastIndex: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }
        
        if (self.navigationController!.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController!.interactivePopGestureRecognizer.enabled = false;
        }
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        //.self.navigationController!.navigationBar.topItem!.title = "User Profile";
        //self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        followerTableView.allowsMultipleSelectionDuringEditing = false
        
        followerTableView.allowsSelectionDuringEditing = true
        
        //self.followerTableView.rowHeight = UITableViewAutomaticDimension;
        self.followerTableView.estimatedRowHeight = 50.0;
        
        self.followerTableView.alwaysBounceVertical = false;        
        
        
        var widthOfTitleBar = TITLE_BAR_WIDTH
        var heightOfBar = TITLE_BAR_HEIGHT        
        
        var view: UIView = UIView(frame: CGRectMake(0, 0, widthOfTitleBar, heightOfBar + 14));    //0 0 220 44
        
        if (mainUser != nil && mainUser!.username != ServerInteractor.getUserName()) {
            //viewing someone else's profile (friend profile page)
            mainUser!.isFanPageUser({(fpUser: Bool?) -> Void in
                if fpUser == nil { // average user
                    self.setNavBarTitle(self.mainUser!.username)
                } else { // fan page user
                    var textToPut = self.mainUser!.username;
                    var userLabel: UILabel = UILabel(frame: CGRectMake(0, 0, widthOfTitleBar, heightOfBar-6))
                    userLabel.textColor = TITLE_TEXT_COLOR;
                    userLabel.text = textToPut;
                    userLabel.font = USER_TITLE_TEXT_FONT;
                    userLabel.textAlignment = NSTextAlignment.Center
                    
                    var fpUserLabel: UILabel = UILabel(frame: CGRectMake(0, heightOfBar-6, widthOfTitleBar, 20))
                    fpUserLabel.textColor = TITLE_TEXT_COLOR;
                    fpUserLabel.text = "Fanpage"
                    fpUserLabel.font = UIFont(name: "Didot-HTF-B24-Bold-Ital", size: 13.0)!;
                    fpUserLabel.textAlignment = NSTextAlignment.Center
                    view.addSubview(fpUserLabel)
                    view.addSubview(userLabel)
                    self.navigationItem.titleView = view
                }
            })
            
            mainUser!.fetchImage({(image: UIImage)->Void in
                self.setUserIconBubble(image)
                self.mainUser!.getNumPosts(){numPosts, error in
                    if error == nil {
                        self.numberPosts.text = String(numPosts!)
                    } else {
                        self.numberPosts.text = "0"
                    }
                    self.numberLikes.text = String(self.mainUser!.getNumLiked())
                    self.getNumFollowers()
                    self.getNumFollowing()
                    self.amMyself = false
                    self.configureSettingButton();
                    self.AnonText.hidden = true
                }
            });
            
            mainUser!.getWebURL({(webURL: String?) -> Void in
                if webURL == nil {
                    self.userWebURL.text = ""
                } else {
                    self.userWebURL.text = webURL
                }
            })
        }
        else { // self profile page
            mainUser = ServerInteractor.getCurrentUser();
            if (ServerInteractor.isAnonLogged()) { //viewing anonymous user profile (myself)
                setNavBarTitle("Anonymous")

                self.userWebURL.text = ""
                
                var tempImage: UIImage = DEFAULT_USER_ICON;
                //self.backImageView.image = tempImage;
                self.backImageView.setImageAndBlur(tempImage);
                AnonText.hidden = true  //<---cringe (damit bala)
                
                self.settingButton.setBackgroundImage(UIImage(), forState: UIControlState.Normal);
                self.settingButton.setTitle("Log In", forState: UIControlState.Normal);
                self.settingButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
                self.setUserIconBubble(tempImage)
                
                self.numberLikes.text = String(self.mainUser!.getNumLiked())
                //friendsButton.hidden = true;
            }
            else { // viewing my own profile (logged in user)
                setNavBarTitle(ServerInteractor.getUserName())
                
                mainUser!.fetchImage({(image: UIImage)->Void in
                    self.setUserIconBubble(image)
                    self.mainUser!.getNumPosts(){numPosts, error in
                        if error == nil {
                            self.numberPosts.text = String(numPosts!)
                        } else {
                            self.numberPosts.text = "0"
                        }
                        self.numberLikes.text = String(self.mainUser!.getNumLiked())
                        self.getNumFollowers()
                        self.getNumFollowing()
                        self.AnonText.hidden = true
                        
                        self.settingButton.setBackgroundImage(SETTINGS_ICON, forState: UIControlState.Normal);
                    }
                });
                
                mainUser!.getWebURL({(webURL: String?) -> Void in
                    if webURL == nil {
                        self.userWebURL.text = ""
                    } else {
                        self.userWebURL.text = webURL
                    }
                })
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        //1. mainUser == nil
        //  a. Anon
        //  b. MyUser (current user)
        //2. receive mainUser from some other view
        //  a. mainUser == currentUser
        //  b. mainUser == some other user thats not me
        
        //numberPosts.text = String(mainUser!["numPosts"].count as Int)
        //numberLikes.text = String(mainUser!["likedPosts"].count as Int)
        //numberPosts.text = String(mainUser!.getNumPosts())
        //numberLikes.text = String(mainUser!.getNumLiked())
        if (options == 0) {
            unclickEverything();
            if (ServerInteractor.isAnonLogged()) {
                options = 2;
                likeButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
                numberLikes.textColor = SELECTED_COLOR;
                myCollectionView.hidden = false
                followerTableView.hidden = true
                collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
                collectionDelegateLikes!.initialSetup();
                AnonText.hidden = true
            } else {
                options = 1;
                postButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
                numberPosts.textColor = SELECTED_COLOR;
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
            }
        }
        else {
            resetDatums(options)
            reRender(options)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        var cellIndices = myCollectionView.indexPathsForVisibleItems()// as Array<NSIndexPath>;
        for cellIndex in cellIndices {
            var cell = myCollectionView.cellForItemAtIndexPath(cellIndex as NSIndexPath)
            if (cell != nil) {
                cell!.alpha = 0;
            }
        }
    }
    
    func setUserIconBubble(image: UIImage) {
//        self.userInfoBackImageView.setImageAndBlur(image);
        self.userInfoBackImageView.setImageAndLightBlur(image)
        self.userInfoBackImageView.alpha = CGFloat(0.6)
        var newUserIcon: UIImage = ServerInteractor.imageWithImage(image, scaledToSize: CGSize(width: USER_ICON_BUTTON_WIDTH, height: USER_ICON_BUTTON_HEIGHT))
        self.userIconButton.setImage(newUserIcon, forState: UIControlState.Normal)
        self.userIconButton.layer.cornerRadius = (self.userIconButton.frame.size.width) / 2
        self.userIconButton.layer.masksToBounds = true
        self.userIconButton.layer.borderWidth = CGFloat(1.8)
        self.userIconButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.userInfoBottomBar.alpha = CGFloat(0.6)
    }
    
    func setNavBarTitle(navBarTitle : String) {
        var userLabel: UILabel = UILabel(frame: CGRectMake(0, 0, TITLE_BAR_WIDTH, TITLE_BAR_HEIGHT+14)) // 14 for fan page user label (not displayed)
        userLabel.textColor = TITLE_TEXT_COLOR;
        userLabel.text = navBarTitle
        userLabel.font = USER_TITLE_TEXT_FONT;
        userLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(userLabel);
        self.navigationItem.titleView = view;
    }
    
    func unclickEverything() {
        postButton.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal);
        numberPosts.textColor = UNSELECTED_COLOR;
        likeButton.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal);
        numberLikes.textColor = UNSELECTED_COLOR;
        followingButton.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal);
        numberFollowing.textColor = UNSELECTED_COLOR;
        followerButton.setTitleColor(UNSELECTED_COLOR, forState: UIControlState.Normal);
        numberFollowers.textColor = UNSELECTED_COLOR;
    }
    
    @IBAction func sideMenuButtonPressed(sender: AnyObject) {
        (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
    }
    
    @IBAction func backPress(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                self.navigationController!.popViewControllerAnimated(true);
            }
        }
    }
    
    @IBAction func changeUserIcon(sender: AnyObject) {
        if (!amMyself) {
            //can't change other people's profile pictures!
            return;
        }
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            var profPicPicker: UIImagePickerController = UIImagePickerController();
            //profPicPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
            profPicPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            profPicPicker.delegate = self;
            profPicPicker.mediaTypes = [kUTTypeImage];
            profPicPicker.allowsEditing = false;
            self.presentViewController(profPicPicker, animated: true, completion: nil);
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        NSLog("Setting profile pic");
        ServerInteractor.updateProfilePicture(image);
        
        //reupdate user profile window with picture
        self.setUserIconBubble(image)
        
        picker.dismissViewControllerAnimated(true, completion: {()->Void in
            CompatibleAlertViews.makeNotice("Updated!", message: "Profile Picture Updated", presenter: self);
        });
    }
    
    
    @IBAction func anonSignIn(sender: UIButton) {
        self.performSegueWithIdentifier("LogOffFromUserSegue", sender: self);
    }
    
    @IBAction func userPosts(sender: AnyObject) {
        unclickEverything();
        postButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
        numberPosts.textColor = SELECTED_COLOR;
        if (options != 1) {
            //collectionDelegatePosts!.resetData()
            //collectionDelegate!.serverFunction = ServerInteractor.getSubmissions;
            //collectionDelegateLikes!.resetData();
            if (ServerInteractor.isAnonLogged()) {
                myCollectionView.hidden = true
                followerTableView.hidden = true
                AnonText.hidden = false
                SignInAnon.hidden = false
                followOthersText.hidden = true
                haveFollowersText.hidden = true
                options = 1
            } else {
                self.mainUser!.getNumPosts(){numPosts, error in
                    if error == nil {
                        self.numberPosts.text = String(numPosts!)
                    } else {
                        self.numberPosts.text = "0"
                    }
//                collectionDelegatePosts!.resetData();
//                collectionDelegateLikes!.resetData()
                    self.resetDatums(self.options)
                    self.options = 1
                    self.collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: self.mainUser);
                    self.collectionDelegatePosts!.initialSetup();
                    //collectionDelegate!.loadSet()
                    self.myCollectionView.hidden = false
                    self.followerTableView.hidden = true
                }
            }
        } else {
            if (ServerInteractor.isAnonLogged()) {
                //collectionDelegatePosts!.resetData();
                collectionDelegateLikes!.initialSetup();
                collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
                collectionDelegateLikes!.initialSetup();
                AnonText.hidden = false
                SignInAnon.hidden = false
                followOthersText.hidden = true
                haveFollowersText.hidden = true
                return
            } else {
                self.mainUser!.getNumPosts(){numPosts, error in
                    if error == nil {
                        self.numberPosts.text = String(numPosts!)
                    } else {
                        self.numberPosts.text = "0"
                    }
                    self.collectionDelegatePosts!.resetData();
                    self.collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: self.mainUser);
                    self.collectionDelegatePosts!.initialSetup();
                }
                //collectionDelegatePosts!.loadSet()
            }
        }
    }
    
    
    @IBAction func userLikes(sender: AnyObject) {
        unclickEverything();
        likeButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
        numberLikes.textColor = SELECTED_COLOR;
        if (options != 2) {
            self.numberLikes.text = String(self.mainUser!.getNumLiked())
//            collectionDelegateLikes!.resetData()
//            collectionDelegatePosts!.resetData();
            resetDatums(options)
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
            myCollectionView.hidden = false
            followerTableView.hidden = true
            AnonText.hidden = true
            options = 2

            SignInAnon.hidden = true
            followOthersText.hidden = true
            haveFollowersText.hidden = true
            //collectionDelegate!.loadSet()
        } else {
            AnonText.hidden = true
            SignInAnon.hidden = true
            followOthersText.hidden = true
            haveFollowersText.hidden = true
            options = 2
            self.numberLikes.text = String(self.mainUser!.getNumLiked())
            collectionDelegateLikes!.resetData();
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
        }
    }
    
    @IBAction func userFollowing(sender: UIButton) {
        unclickEverything();
        followingButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
        numberFollowing.textColor = SELECTED_COLOR;
        if (ServerInteractor.isAnonLogged()) {
            collectionDelegateLikes!.resetData();
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
            myCollectionView.hidden = true
            followerTableView.hidden = true
            followOthersText.hidden = false
            SignInAnon.hidden = false
            AnonText.hidden = true
            haveFollowersText.hidden = true
        } else {
            getNumFollowing();
            getNumFollowers();
            if (options != 3) {
                options = 3
                resetDatums(options)
                myCollectionView.hidden = true
                followerTableView.hidden = false
                getFollowing()
            }
        }
    }
    
    
    @IBAction func userFollowers(sender: UIButton) {
        unclickEverything();
        followerButton.setTitleColor(SELECTED_COLOR, forState: UIControlState.Normal);
        numberFollowers.textColor = SELECTED_COLOR;
        if (ServerInteractor.isAnonLogged()) {
            collectionDelegateLikes!.resetData();
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
            myCollectionView.hidden = true
            followerTableView.hidden = true
            haveFollowersText.hidden = false
            SignInAnon.hidden = false
            AnonText.hidden = true
            followOthersText.hidden = true
        } else {
            getNumFollowing();
            getNumFollowers();
            if (options != 4) {
                options = 4
                resetDatums(options)
                myCollectionView.hidden = true
                followerTableView.hidden = false
                getFollowers()
            }
        }
    }
    
    func getFollowers() {
        ServerInteractor.findFollowers(mainUser!,
            retFunction: {
            (retList: Array<FriendEncapsulator?>) in
                self.friendList = retList
            self.reloadDatums();
            }) //--> change this to getFriends(srcFriend)
    }
    
    func getFollowing() {
        ServerInteractor.findFollowing(mainUser!,
            retFunction: {
                (retList: Array<FriendEncapsulator?>) in
                self.friendList = retList
                self.reloadDatums();
            }) //--> change this to getFriends(srcFriend)
    }

    func getNumFollowing() {
        //var numFollowing = ServerInteractor.findNumFollowing(mainUser!.username)
        //println("\(numFollowing) sdkjfnvkjdnvkjsndfljvsdlfjnvsdjfv OHH YEAADFJKVNDKVJN WOOTOWOTOWOWOT")
        //return numFollowing
        ServerInteractor.findNumFollowing(mainUser!,
            retFunction: {
                (retInt: Int) in
                var numFollowing: Int = retInt
                self.numberFollowing.text = String(numFollowing)
        })
    }
    
    func getNumFollowers() {
        //var numFollowers = ServerInteractor.findNumFollowers(mainUser!.username)
        //println(String(numFollowers) + "sdkjfnvkjdnvkjsndfljvsdlfjnvsdjfv OHH YEAADFJKVNDKVJN WOOTOWOTOWOWOT")
        //return numFollowers
        ServerInteractor.findNumFollowers(mainUser!,
            retFunction: {
                (retInt: Int) in
                var numFollowers: Int = retInt
                self.numberFollowers.text = String(numFollowers)
        })

    }
    
    func reloadDatums() {
        self.followerTableView.reloadData();
    }
    
    func resetDatums(options: Int) {
        if (options == 3 || options == 4) {
            if (ServerInteractor.isAnonLogged()) {
                collectionDelegateLikes!.resetData()
            } else {
                collectionDelegateLikes!.resetData()
                collectionDelegatePosts!.resetData();
            }
        } else {
            if (options == 1) {
                collectionDelegateLikes!.resetData()
            } else {
                if (options == 2) {
                    if (ServerInteractor.isAnonLogged()) {
                        collectionDelegateLikes!.resetData()
                    } else {
                        collectionDelegatePosts!.resetData();
                    }
                }
            }
        }
    }
    
    func reRender(options: Int) {
        if (options == 1) {
            collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
            collectionDelegatePosts!.initialSetup();
        }
        if (options == 2) {
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
        }
        if (options == 3) {
            getFollowing()
        }
        if (options == 4) {
            getFollowers()
        }
    }
    
    func receiveUserInfo(displayFriend: FriendEncapsulator) {
        mainUser = displayFriend;
    }
    
    /*func resizingImage(image: UIImage) -> UIImage {
        image.size.height = self.navigationController!.navigationBar.frame.size.height
        image.size.width = self.navigationController!.navigationBar.frame.size.width
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func notifyFailure(message: String) {
        var alert = UIAlertController(title: "Friend?", message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }*/
    
    
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        /*if (segue != nil && segue.identifier != nil?) {
            if (segue.identifier == "SeeFriendsSegue") {
                if (mainUser != nil) {
                    //(segue!.destinationViewController as FriendTableViewController).receiveMasterFriend(mainUser!);
                }
            }*/
            /*else if (segue!.identifier == "ImagePostSegue") {
                if (mainUser) {
                    var indexPaths: [NSIndexPath] = myCollectionView.indexPathsForSelectedItems() as [NSIndexPath];
                    if (indexPaths.count > 0) {
                        var indexPath: NSIndexPath = indexPaths[0];
                        if (options == 1) {
                            (segue!.destinationViewController as ImagePostNotifViewController).receiveImagePost(collectionDelegatePosts!.getPost(indexPath.row));
                        }
                        else {
                            (segue!.destinationViewController as ImagePostNotifViewController).receiveImagePost(collectionDelegateLikes!.getPost(indexPath.row));
                        }
                    }
                    //(segue!.destinationViewController as ImagePostNotifViewController).receiveImagePost(loadedPosts[lastSelect]!);
                }
            }*/
        //}
    }
    
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Test submission post");
        //lets also try adding to user field
    }
    //--------------------------TableView Functions-------------------------
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count;
    }
    
    /*func tableView(tableView: UITableView!, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath!) -> String! {
        if (options == 3){
            return "Block"
        }
        return "Unfollow"
    }*/
    
    func configureSettingButton() {
        ServerInteractor.amFollowingUser(mainUser!, retFunction: {(amFollowing: Bool) in
            self.friendAction = amFollowing;
            if (amFollowing == true) {
                self.settingButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal)
            }
            else if (amFollowing == false) {
                self.settingButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
            }
            else {
                //do nothing, server failed to fetch!
                NSLog("Failure? \(amFollowing)")
            }
        });
    }
    
    @IBAction func settingButtonPressed(sender: AnyObject) {
        if (!amMyself) {
            var username = mainUser!.username;
            if (!friendAction) {
                //follow me
                //ServerInteractor.postFollowerNotif(username, controller: self);
                ServerInteractor.addAsFollower(mainUser!);
                
                //update button
                self.friendAction = true
                self.settingButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal)
            }
            else if (friendAction == true) {
                //unfollow me (if u wish!)
                
                self.alerter = CompatibleAlertViews(presenter: self);
                alerter!.makeNoticeWithAction("Unfollow "+username, message: "Unfollow "+username+"?", actionName: "Unfollow", buttonAction: {
                    () in
                    ServerInteractor.removeAsFollower(self.mainUser!);
                    //update button
                    self.friendAction = false
                    self.settingButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
                });
            }
        } else {
            if (ServerInteractor.isAnonLogged()) {
                //segue to go to home screen
                self.performSegueWithIdentifier("LogOffFromUserSegue", sender: self);
            }
            else {
                self.performSegueWithIdentifier("GotoSettingsSegue", sender: self);
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UserTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("FollowerCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        
        var index: Int = indexPath.row;
        
        if (friendList[index] != nil) {
            var text = friendList[index]!.username;
            cell.extraConfigurations(friendList[index], message: text, enableFriending: true, sender: self);
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        return cell
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int = indexPath.row;
        
        if (friendList[index] != nil) {
            var text = friendList[index]!.username;
            var recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(friendList[index], message: text, enableFriending: true);
            
            return recHeight;
        }
        return tableView.estimatedRowHeight;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.navigationController != nil) {
            var temp = indexPath.row
            var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            (nextBoard as UserProfileViewController).receiveUserInfo(friendList[temp]!);
            self.navigationController!.pushViewController(nextBoard, animated: true);
        }
    }
}
