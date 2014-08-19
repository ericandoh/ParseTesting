//
//  UserProfileViewController.swift
//  ParseStarterProject
//
//  Created by Bala on 7/25/14.
//
//

import Foundation

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var settingsButton: UIButton!
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
    
    var userIcon: UIImageView?
    
    var options: Int = 0;
    
    var collectionDelegatePosts: ImagePostCollectionDelegate?;
    var collectionDelegateLikes: ImagePostCollectionDelegate?;

    var friendList: Array<FriendEncapsulator?> = [];
    
    //var lastIndex: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0);
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        
        if ((self.navigationController) != nil) {
            if (self.navigationController.viewControllers.count > 1) {
                backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }
        
        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
        
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController.navigationBar.shadowImage = UIImage();
        self.navigationController.navigationBar.translucent = true;
        self.navigationController.view.backgroundColor = UIColor.clearColor();
        //self.navigationController.navigationBar.topItem.title = "User Profile";
        //self.navigationController.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        followerTableView.allowsMultipleSelectionDuringEditing = false
        
        followerTableView.allowsSelectionDuringEditing = true
        
        //self.followerTableView.rowHeight = UITableViewAutomaticDimension;
        self.followerTableView.estimatedRowHeight = 50.0;
        
        self.followerTableView.alwaysBounceVertical = false;        
        
        
        var widthOfTitleBar = TITLE_BAR_WIDTH;
        var widthOfUserIconImg = USER_ICON_WIDTH;
        var heightOfBar = TITLE_BAR_HEIGHT;
        var spacing = TITLE_BAR_ICON_TEXT_SPACING;
        
        
        var view: UIView = UIView(frame: CGRectMake(0, 0, widthOfTitleBar, heightOfBar));    //0 0 160 40
        
        if (mainUser != nil && mainUser!.username != ServerInteractor.getUserName()) {
            
            var textToPut = mainUser!.username;
            var labelSize = (textToPut as NSString).sizeWithAttributes([NSFontAttributeName: USER_TITLE_TEXT_FONT]);
            var widthOfLabel = min(labelSize.width + 3, widthOfTitleBar - widthOfUserIconImg - spacing);
            var extraMargin = (widthOfTitleBar - widthOfUserIconImg - widthOfLabel - spacing) / 2.0;
            userIcon = UIImageView(frame: CGRectMake(extraMargin, 0, widthOfUserIconImg, heightOfBar));
            var userLabel: UILabel = UILabel(frame: CGRectMake(spacing + extraMargin + widthOfUserIconImg, 0, widthOfLabel, heightOfBar))
            userLabel.textColor = TITLE_TEXT_COLOR;
            userLabel.text = textToPut;
            userLabel.font = USER_TITLE_TEXT_FONT;
            
            mainUser!.fetchImage({(image: UIImage)->Void in
                //self.userIcon.image = image;
                //self.backImageView.image = image;
                self.backImageView.setImageAndBlur(image);
                var newUserIcon: UIImage = ServerInteractor.imageWithImage(image, scaledToSize: CGSize(width: 40, height: 40))
                self.userIcon!.image = newUserIcon
                self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                self.userIcon!.layer.masksToBounds = true
                self.userIcon!.layer.borderWidth = 0
                self.navigationItem.titleView = view;
                //userLabel.text = self.mainUser!.username
                view.addSubview(self.userIcon!);
                view.addSubview(userLabel);
                NSLog("a");
                self.numberPosts.text = String(self.mainUser!.getNumPosts())
                self.numberLikes.text = String(self.mainUser!.getNumLiked())
                self.getNumFollowers()
                self.getNumFollowing()
                //self.settingsButton.hidden = true
                self.amMyself = false
                self.configureSettingsButton();
                self.AnonText.hidden = true
            });
            //settingsButton.hidden = true;       //we could make this so this points to remove friend or whatnot
        }
        else {
            mainUser = ServerInteractor.getCurrentUser();
            if (ServerInteractor.isAnonLogged()) {
                
                var textToPut = "Anonymous";
                var labelSize = (textToPut as NSString).sizeWithAttributes([NSFontAttributeName: USER_TITLE_TEXT_FONT]);
                var widthOfLabel = min(labelSize.width + 3, widthOfTitleBar - widthOfUserIconImg - spacing);
                var extraMargin = (widthOfTitleBar - widthOfUserIconImg - widthOfLabel - spacing) / 2.0;
                userIcon = UIImageView(frame: CGRectMake(extraMargin, 0, widthOfUserIconImg, heightOfBar));
                var userLabel: UILabel = UILabel(frame: CGRectMake(spacing + extraMargin + widthOfUserIconImg, 0, widthOfLabel, heightOfBar))
                userLabel.textColor = TITLE_TEXT_COLOR;
                userLabel.text = textToPut;
                userLabel.font = USER_TITLE_TEXT_FONT;
                var tempImage: UIImage = DEFAULT_USER_ICON;
                //self.backImageView.image = tempImage;
                self.backImageView.setImageAndBlur(tempImage);
                var newUserIcon: UIImage = ServerInteractor.imageWithImage(tempImage, scaledToSize: CGSize(width: 40, height: 40))
                self.userIcon!.image = newUserIcon
                self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                self.userIcon!.layer.masksToBounds = true
                self.userIcon!.layer.borderWidth = 0
                self.navigationItem.titleView = view;
                view.addSubview(self.userIcon!);
                view.addSubview(userLabel);
                AnonText.hidden = true  //<---cringe (damit bala)
                self.settingsButton.setBackgroundImage(UIImage(), forState: UIControlState.Normal);
                self.settingsButton.setTitle("Log In", forState: UIControlState.Normal);
                self.settingsButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
                self.numberLikes.text = String(self.mainUser!.getNumLiked())
                //friendsButton.hidden = true;
            }
            else {
                // Do any additional setup after loading the view.
                
                var textToPut = ServerInteractor.getUserName();
                var labelSize = (textToPut as NSString).sizeWithAttributes([NSFontAttributeName: USER_TITLE_TEXT_FONT]);
                var widthOfLabel = min(labelSize.width + 3, widthOfTitleBar - widthOfUserIconImg - spacing);
                var extraMargin = (widthOfTitleBar - widthOfUserIconImg - widthOfLabel - spacing) / 2.0;
                userIcon = UIImageView(frame: CGRectMake(extraMargin, 0, widthOfUserIconImg, heightOfBar));
                var userLabel: UILabel = UILabel(frame: CGRectMake(spacing + extraMargin + widthOfUserIconImg, 0, widthOfLabel, heightOfBar))
                userLabel.textColor = TITLE_TEXT_COLOR;
                userLabel.text = textToPut;
                userLabel.font = USER_TITLE_TEXT_FONT;
                
                mainUser!.fetchImage({(fetchedImage: UIImage)->Void in
                    //self.userIcon.image = fetchedImage;
                    //self.backImageView.image = fetchedImage;
                    self.backImageView.setImageAndBlur(fetchedImage);
                    var newUserIcon = ServerInteractor.imageWithImage(fetchedImage, scaledToSize: CGSize(width: 40, height: 40))
                    self.userIcon!.image = newUserIcon
                    self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                    self.userIcon!.layer.masksToBounds = true
                    self.userIcon!.layer.borderWidth = 0
                    self.navigationItem.titleView = view;
                    view.addSubview(self.userIcon!);
                    view.addSubview(userLabel);
                    NSLog("B")
                    self.numberPosts.text = String(self.mainUser!.getNumPosts())
                    self.numberLikes.text = String(self.mainUser!.getNumLiked())
                    self.getNumFollowers()
                    self.getNumFollowing()
                    self.AnonText.hidden = true
                    self.settingsButton.setBackgroundImage(SETTINGS_ICON, forState: UIControlState.Normal);
                });
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
                cell.alpha = 0;
            }
        }
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
    
    
    @IBAction func backPress(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController.viewControllers.count == 1) {
                //this is the only vc on the stack - move to menu
                (self.navigationController.parentViewController as SideMenuManagingViewController).openMenu();
            }
            else {
                //(self.navigationController.parentViewController as SideMenuManagingViewController).openMenu()
                self.navigationController.popViewControllerAnimated(true);
            }
        }
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
                self.numberPosts.text = String(self.mainUser!.getNumPosts())
//                collectionDelegatePosts!.resetData();
//                collectionDelegateLikes!.resetData()
                resetDatums(options)
                options = 1
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
                //collectionDelegate!.loadSet()
                myCollectionView.hidden = false
                followerTableView.hidden = true
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
                self.numberPosts.text = String(self.mainUser!.getNumPosts())
                collectionDelegatePosts!.resetData();
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
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
        ServerInteractor.findFollowers(mainUser!.username,
            retFunction: {
            (retList: Array<FriendEncapsulator?>) in
                self.friendList = retList
            self.reloadDatums();
            }) //--> change this to getFriends(srcFriend)
    }
    
    func getFollowing() {
        ServerInteractor.findFollowing(mainUser!.username,
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
        ServerInteractor.findNumFollowing(mainUser!.username,
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
        ServerInteractor.findNumFollowers(mainUser!.username,
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
        image.size.height = self.navigationController.navigationBar.frame.size.height
        image.size.width = self.navigationController.navigationBar.frame.size.width
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
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if (segue != nil && segue!.identifier != nil) {
            if (segue!.identifier == "SeeFriendsSegue") {
                if (mainUser != nil) {
                    //(segue!.destinationViewController as FriendTableViewController).receiveMasterFriend(mainUser!);
                }
            }
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
        }
    }
    
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Test submission post");
        //lets also try adding to user field
    }
    //--------------------------TableView Functions-------------------------
    
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return friendList.count;
    }
    
    /*func tableView(tableView: UITableView!, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath!) -> String! {
        if (options == 3){
            return "Block"
        }
        return "Unfollow"
    }*/
    
    func configureSettingsButton() {
        ServerInteractor.amFollowingUser(mainUser!.username, retFunction: {(amFollowing: Bool) in
            self.friendAction = amFollowing;
            if (amFollowing == true) {
                self.settingsButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
            }
            else if (amFollowing == false) {
                self.settingsButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
            }
            else {
                //do nothing, server failed to fetch!
                NSLog("Failure? \(amFollowing)")
            }
        });
    }
    
    @IBAction func settings(sender: AnyObject) {
        if (!amMyself) {
            var username = mainUser!.username;
            if (!friendAction) {
                //follow me
                //ServerInteractor.postFollowerNotif(username, controller: self);
                ServerInteractor.addAsFollower(username);
                
                //update button
                self.friendAction = true
                self.settingsButton.setBackgroundImage(FOLLOWED_ME_ICON, forState: UIControlState.Normal);
            }
            else if (friendAction == true) {
                //unfollow me (if u wish!)
                
                var alerter = CompatibleAlertViews(presenter: self);
                alerter.makeNoticeWithAction("Unfollow "+username, message: "Unfollow "+username+"?", actionName: "Unfollow", buttonAction: {
                    () in
                    ServerInteractor.removeAsFollower(username);
                    //update button
                    self.friendAction = false
                    self.settingsButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
                });
                
                /*
                let alert: UIAlertController = UIAlertController(title: "Unfollow "+username, message: "Unfollow "+username+"?", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                    ServerInteractor.removeAsFollower(username);
                    //update button
                    self.friendAction = false
                    self.settingsButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal)
                }));
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                    //canceled
                }));
                self.presentViewController(alert, animated: true, completion: nil)*/
            }
            else {
                //no action
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
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: UserTextTableViewCell = tableView!.dequeueReusableCellWithIdentifier("FollowerCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        
        var index: Int = indexPath.row;
        
        if (friendList[index] != nil) {
            var text = friendList[index]!.username;
            cell.extraConfigurations(friendList[index], message: text, enableFriending: true, sender: self);
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        return cell
        
    }
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
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
            var nextBoard : UIViewController = self.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            (nextBoard as UserProfileViewController).receiveUserInfo(friendList[temp]!);
            self.navigationController.pushViewController(nextBoard, animated: true);
        }
    }
}
