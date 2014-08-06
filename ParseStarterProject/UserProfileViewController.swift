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
    @IBOutlet var friendsButton: UIButton!
    @IBOutlet var numberPosts: UILabel!
    @IBOutlet var numberLikes: UILabel!
    
    @IBOutlet weak var numberFollowers: UILabel!
    @IBOutlet weak var numberFollowing: UILabel!
    
    @IBOutlet weak var AnonText: UITextView!
    
    @IBOutlet var followerTableView: UITableView!
    var mainUser: FriendEncapsulator?;
    
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
    
    override func viewDidLoad()  {
        super.viewDidLoad();
        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
        followerTableView.allowsMultipleSelectionDuringEditing = false
        
        followerTableView.allowsSelectionDuringEditing = true
        
        self.followerTableView.rowHeight = UITableViewAutomaticDimension;
        self.followerTableView.estimatedRowHeight = 60.0;
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
        var view: UIView = UIView(frame: CGRectMake(0, 0, 160, 40));
        var userLabel: UILabel = UILabel(frame: CGRectMake(75, 0, 80, 30))
        userIcon = UIImageView(frame: CGRectMake(40, 40, 40, 40))
        userIcon!.frame = CGRectMake(20, -5, 40, 40);
        if (mainUser != nil && mainUser!.username != ServerInteractor.getUserName()) {
            userLabel.text = mainUser!.getName({userLabel.text = self.mainUser!.getName({NSLog("Failed twice to fetch name")})});
            mainUser!.fetchImage({(image: UIImage)->Void in
                //self.userIcon.image = image;
                var newUserIcon: UIImage = ServerInteractor.imageWithImage(image, scaledToSize: CGSize(width: 40, height: 40))
                self.userIcon!.image = newUserIcon
                self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                self.userIcon!.layer.masksToBounds = true
                self.userIcon!.layer.borderWidth = 0
                self.navigationItem.titleView = view;
                userLabel.text = self.mainUser!.username
                view.addSubview(self.userIcon!);
                view.addSubview(userLabel);
                self.numberPosts.text = String(self.mainUser!.getNumPosts())
                self.numberLikes.text = String(self.mainUser!.getNumLiked())
                self.getNumFollowers()
                self.getNumFollowing()
                //self.settingsButton.hidden = true
                self.settingsButton.setImage(LOADING_IMG, forState: UIControlState.Normal)
                });
            //settingsButton.hidden = true;       //we could make this so this points to remove friend or whatnot
        }
        else {
            mainUser = ServerInteractor.getCurrentUser();
            if (ServerInteractor.isAnonLogged()) {
                var tempImage: UIImage = DEFAULT_USER_ICON;
                var newUserIcon: UIImage = ServerInteractor.imageWithImage(tempImage, scaledToSize: CGSize(width: 40, height: 40))
                self.userIcon!.image = newUserIcon
                self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                self.userIcon!.layer.masksToBounds = true
                self.userIcon!.layer.borderWidth = 0
                self.navigationItem.titleView = view;
                userLabel.text = "Anon User";
                view.addSubview(self.userIcon!);
                view.addSubview(userLabel);
                friendsButton.hidden = true;
            }
            else {
                // Do any additional setup after loading the view.
                userLabel.text = ServerInteractor.getUserName();
                mainUser!.fetchImage({(fetchedImage: UIImage)->Void in
                    //self.userIcon.image = fetchedImage;
                    var newUserIcon = ServerInteractor.imageWithImage(fetchedImage, scaledToSize: CGSize(width: 40, height: 40))
                    self.userIcon!.image = newUserIcon
                    self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                    self.userIcon!.layer.masksToBounds = true
                    self.userIcon!.layer.borderWidth = 0
                    self.navigationItem.titleView = view;
                    userLabel.text = self.mainUser!.username
                    view.addSubview(self.userIcon!);
                    view.addSubview(userLabel);
                    self.numberPosts.text = String(self.mainUser!.getNumPosts())
                    self.numberLikes.text = String(self.mainUser!.getNumLiked())
                    self.getNumFollowers()
                    self.getNumFollowing()
                    });
            }
        }
        if (options == 0) {
            options = 1;
            if (ServerInteractor.isAnonLogged()) {
                myCollectionView.hidden = true
                followerTableView.hidden = true
                collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
                AnonText.hidden = false
            } else {
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
            }
        }
    }
    
    
    @IBAction func userPosts(sender: AnyObject) {
        if (options != 1) {
            //collectionDelegatePosts!.resetData()
            //collectionDelegate!.serverFunction = ServerInteractor.getSubmissions;
            options = 1
            //collectionDelegateLikes!.resetData();
            if (ServerInteractor.isAnonLogged()) {
                myCollectionView.hidden = true
                followerTableView.hidden = true
                AnonText.hidden = false
            } else {
                collectionDelegatePosts!.resetData();
                collectionDelegateLikes!.resetData()
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
                //collectionDelegate!.loadSet()
                myCollectionView.hidden = false
                followerTableView.hidden = true
            }
        } else {
            if (ServerInteractor.isAnonLogged()) {
                //collectionDelegatePosts!.resetData();
                return
            } else {
                collectionDelegatePosts!.resetData();
                
                collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
                collectionDelegatePosts!.initialSetup();
                //collectionDelegatePosts!.loadSet()
            }
        }
    }
    
    
    @IBAction func userLikes(sender: AnyObject) {
        if (options != 2) {
            collectionDelegateLikes!.resetData()
            collectionDelegatePosts!.resetData();
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
            options = 2
            myCollectionView.hidden = false
            followerTableView.hidden = true
            AnonText.hidden = true
            //collectionDelegate!.loadSet()
        } else {
            options = 2
            collectionDelegateLikes!.resetData();
            collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
            collectionDelegateLikes!.initialSetup();
        }
    }
    
    @IBAction func userFollowing(sender: UIButton) {
        if (options != 3) {
            options = 3
            myCollectionView.hidden = true
            followerTableView.hidden = false
            getFollowing()
        }
    }
    
    
    @IBAction func userFollowers(sender: UIButton) {
        if (options != 4) {
            options = 4
            myCollectionView.hidden = true
            followerTableView.hidden = false
            getFollowers()
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
        NSLog("d")
        self.followerTableView.reloadData();
        NSLog("n")
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
    
    func notifyFailure(message: String) {
        var alert = UIAlertController(title: "Friend?", message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
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
    
    @IBAction func settings(sender: AnyObject) {
        if (mainUser != nil && mainUser!.username != ServerInteractor.getUserName()) {
            ServerInteractor.addAsFollower(mainUser!.username)
            ServerInteractor.postFollowerNotif(mainUser!.username, controller: self);
            //settingsButton.setImage(ENDING_IMG, forState: UIControlState.Normal)
        } else {
            self.performSegueWithIdentifier("GotoSettingsSegue", sender: self);
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.navigationController != nil) {
            var temp = indexPath.row
            var nextBoard : UIViewController = self.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            (nextBoard as UserProfileViewController).receiveUserInfo(friendList[temp]!);
            self.navigationController.pushViewController(nextBoard, animated: true);
        }
    }
}
