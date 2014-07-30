//
//  UserProfileViewController.swift
//  ParseStarterProject
//
//  Created by temp on 7/25/14.
//
//

import Foundation

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet var settingsButton: UIButton
    @IBOutlet var myCollectionView: UICollectionView
    @IBOutlet var friendsButton: UIButton
    @IBOutlet var numberPosts: UILabel
    @IBOutlet var numberLikes: UILabel
    
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

    override func viewDidLoad()  {
        super.viewDidLoad();
        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        numberPosts.text = String(PFUser.currentUser()["numPosts"] as Int)
        numberLikes.text = String(PFUser.currentUser()["likedPosts"].count)
        var view: UIView = UIView(frame: CGRectMake(0, 0, 160, 40));
        var userLabel: UILabel = UILabel(frame: CGRectMake(75, 0, 80, 30))
        //self.navigationItem.titleView = CGRect(0, 0, 40, 40)
        userIcon = UIImageView(frame: CGRectMake(40, 40, 40, 40))
        userIcon!.layer.cornerRadius = (userIcon!.frame.size.width) / 2
        NSLog("\(userIcon!.layer.cornerRadius)")
        userIcon!.layer.masksToBounds = true
        userIcon!.layer.borderWidth = 0
        NSLog("\(userIcon!.frame.size.width)")
        //userIcon!.image = DEFAULT_USER_ICON;
        //self.navigationItem.titleView = userIcon
        userIcon!.frame = CGRectMake(20, -5, 40, 40);
        //self.navigationItem.titleView.frame = CGRectMake(-10, -10, 40, 40)
        if (mainUser && mainUser!.username != ServerInteractor.getUserName()) {
            userLabel.text = mainUser!.getName({userLabel.text = self.mainUser!.getName({NSLog("Failed twice to fetch name")})});
            mainUser!.fetchImage({(image: UIImage)->Void in
                //self.userIcon.image = image;
                var newUserIcon: UIImage = self.imageWithImage(image, scaledToSize: CGSize(width: 40, height: 40))
                self.userIcon!.image = newUserIcon
                self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                NSLog("\(self.userIcon!.layer.cornerRadius)")
                });
            //logOffButton.hidden = true;         //same as below
            settingsButton.hidden = true;       //we could make this so this points to remove friend or whatnot
        }
            /* else {
            var isLinkedToFacebook: Bool = PFFacebookUtils.isLinkedWithUser(PFUser.currentUser())
            if (isLinkedToFacebook){
            userNameLabel.text = ServerInteractor.getUserName()
            }*/
        else {
            if (ServerInteractor.isAnonLogged()) {
                userLabel.text = "Not logged in";
                //logOffButton.setTitle("Sign In", forState: UIControlState.Normal)
                self.userIcon!.image = DEFAULT_USER_ICON;
                //var newUserIcon = self.imageWithImage(image, scaledToSize: self.navigationController.navigationBar.frame.size)
                friendsButton.hidden = true;
            }
            else {
                mainUser = ServerInteractor.getCurrentUser();
                // Do any additional setup after loading the view.
                userLabel.text = ServerInteractor.getUserName();
                mainUser!.fetchImage({(fetchedImage: UIImage)->Void in
                    //self.userIcon.image = fetchedImage;
                    var newUserIcon = self.imageWithImage(fetchedImage, scaledToSize: CGSize(width: 40, height: 40))
                    self.userIcon!.image = newUserIcon
                    self.userIcon!.layer.cornerRadius = (self.userIcon!.frame.size.width) / 2
                    NSLog("\(self.userIcon!.layer.cornerRadius)")
                    NSLog("\(self.userIcon!.frame.size.width)")
                    self.userIcon!.layer.masksToBounds = true
                    self.userIcon!.layer.borderWidth = 0
                    NSLog("\(self.userIcon!.frame.size.width)")
                    //userIcon!.image = DEFAULT_USER_ICON;
                    //self.navigationItem.titleView = self.userIcon;
                    self.navigationItem.titleView = view;
                    //self.userIcon!.frame = CGRectMake(30, 0, 40, 40)
                    //self.navigationItem.titleView.frame = CGRectMake(30, 0, 40, 40)
                    userLabel.text = self.mainUser!.username
                    view.addSubview(self.userIcon!);
                    view.addSubview(userLabel);
                    });
            }
        }
        options = 1;
        collectionDelegatePosts = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getSubmissions, sender: self, user: mainUser);
        collectionDelegateLikes = ImagePostCollectionDelegate(disableOnAnon: true, collectionView: self.myCollectionView, serverFunction: ServerInteractor.getLikedPosts, sender: self, user: mainUser);
        collectionDelegatePosts!.initialSetup();
    }
    
    
    @IBAction func userPosts(sender: AnyObject) {
        if (options != 1) {
            //collectionDelegatePosts!.resetData()
            //collectionDelegate!.serverFunction = ServerInteractor.getSubmissions;
            options = 1
            collectionDelegateLikes!.resetData();
            collectionDelegatePosts!.resetData();
            collectionDelegatePosts!.initialSetup();
            //collectionDelegate!.loadSet()
        } else {
            collectionDelegatePosts!.loadSet()
        }
    }
    
    
    @IBAction func userLikes(sender: AnyObject) {
        if (options != 2) {
            collectionDelegatePosts!.resetData();
            collectionDelegateLikes!.resetData()
            collectionDelegateLikes!.initialSetup();
            options = 2
            //collectionDelegate!.loadSet()
        } else {
            options = 2
            collectionDelegateLikes!.loadSet()
        }
    }
    
    
    func receiveUserInfo(displayFriend: FriendEncapsulator) {
        mainUser = displayFriend;
    }
    
    /*func resizingImage(image: UIImage) -> UIImage {
        image.size.height = self.navigationController.navigationBar.frame.size.height
        image.size.width = self.navigationController.navigationBar.frame.size.width
    }*/
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        var rect: CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image.drawInRect(rect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
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
        
        if (segue && segue!.identifier != nil) {
            if (segue!.identifier == "SeeFriendsSegue") {
                if (mainUser) {
                    (segue!.destinationViewController as FriendTableViewController).receiveMasterFriend(mainUser!);
                }
            }
            else if (segue!.identifier == "ImagePostSegue") {
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
            }
        }
    }
    
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Test submission post");
        //lets also try adding to user field
    }
}
