//
//  UserProfileViewController.swift
//  ParseStarterProject
//
//  Created by temp on 7/25/14.
//
//

import Foundation

import UIKit

class OurUIImageView: UIImageView {
    
    
}


class UserProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var settingsButton: UIButton
    @IBOutlet var myCollectionView: UICollectionView
    @IBOutlet var friendsButton: UIButton
    
    var mainUser: FriendEncapsulator?;
    
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
    
    var userIcon: UIImageView?
    
    /*init(coder aDecoder: NSCoder!)  {
        super.init(coder: aDecoder);
    }*/
    
    var options: Int = 0;
    
    @IBAction func userPosts(sender: AnyObject) {
        if (options != 1) {
            resetData()
            options = 1
            loadSet()
        } else {
            options = 1
            loadSet()
        }
    }
    
    
    @IBAction func userLikes(sender: AnyObject) {
        if (options != 2) {
            resetData()
            options = 2
            loadSet()
        } else {
            options = 2
            loadSet()
        }
    }
    
    @IBOutlet var numberPosts: UILabel
    
    
    @IBOutlet var numberLikes: UILabel
    

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
        //}
        //start fetching submission posts for user, for first set here
        //loadedUpTo = 0;
        hitEnd = false;
        //loadedPosts = [];
        if (!ServerInteractor.isAnonLogged()) {
            loadSet();
        }
        else {
            loadedUpTo = 0;
            hitEnd = true;
            endLoadCount = 0;
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
                        NSLog("Index path is \(indexPath.row)");
                        (segue!.destinationViewController as ImagePostNotifViewController).receiveImagePost(loadedPosts[indexPath.row]!);
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
    func receiveNumQuery(size: Int) {
        var needAmount: Int;
        if (size < MYPOST_LOAD_COUNT) {
            hitEnd = true;
            endLoadCount = size;
            needAmount = (loadedUpTo * MYPOST_LOAD_COUNT) + endLoadCount;
        }
        else {
            endLoadCount = 0;
            loadedUpTo += 1;
            needAmount = loadedUpTo * MYPOST_LOAD_COUNT;
        }
        if (loadedPosts.count < needAmount) {
            loadedPosts += Array<ImagePostStructure?>(count: needAmount - loadedPosts.count, repeatedValue: nil);
        }
        myCollectionView.reloadData();
    }
    func receiveImagePostWithImage(loaded: ImagePostStructure, index: Int) {
        //called by getSubmissions for when image at index x is loaded in...
        var realIndex: Int;
        if (hitEnd) {
            realIndex = index + (loadedUpTo * MYPOST_LOAD_COUNT);
        }
        else {
            realIndex = index + ((loadedUpTo - 1) * MYPOST_LOAD_COUNT);
        }
        loadedPosts[realIndex] = loaded;
        
        for path : AnyObject in myCollectionView.indexPathsForVisibleItems() {
            if ((path as NSIndexPath).row == realIndex) {
                var cell: SinglePostCollectionViewCell = myCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: realIndex, inSection: 0)) as SinglePostCollectionViewCell;
                //do stuff with cell
                configureCell(cell, index: realIndex);
            }
        }
        isLoading = false;  //still loading cells in, but setting indexes are ok
    }
    //configures current cell at index with the appropriate post in loadedPosts
    //assumes post at index is already fetched from server
    func configureCell(cell: SinglePostCollectionViewCell, index: Int) {
        var post: ImagePostStructure = loadedPosts[index]!;
        //configure cell to set image here, etc.
        cell.postLabel.text = "Cell \(index)"
        cell.imageView.image = post.image;
    }
    
    func resetData() {
        loadedUpTo = 0;
        
        endLoadCount = 0;
        
        hitEnd = false;
        
        isLoading = false;
       
        options = 0;
    }
    
    func loadSet() {
        if (isLoading) {
            return;
        }
        isLoading = true;
        //loadedUpTo += 1;
        //loadedPosts += Array<ImagePostStructure?>(count: MYPOST_LOAD_COUNT, repeatedValue: nil);
        //start loading next set of MYPOST_LOAD_COUNT here
        //ServerInteractor.getSubmissions()...; with receiveNumQuery, receiveImagePostWithImage
        //broke here
        if (options == 1) {
            ServerInteractor.getSubmissions((loadedUpTo)*MYPOST_LOAD_COUNT, loadCount: MYPOST_LOAD_COUNT, user: mainUser!, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        } else if (options == 2) {
            ServerInteractor.getLikedPosts((loadedUpTo)*MYPOST_LOAD_COUNT, loadCount: MYPOST_LOAD_COUNT, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
    }
    //----------------------collectionview methods------------------------------
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return loadedUpTo * MYPOST_LOAD_COUNT + endLoadCount;
    }
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell: SinglePostCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCell", forIndexPath: indexPath) as SinglePostCollectionViewCell;
        
        if (loadedPosts[indexPath.row]) {
            //load in cell
            configureCell(cell, index: indexPath.row)
        }
        else {
            //cell will get fetched, wait
        }
        
        return cell;
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        //lastSelect = indexPath!.row;
        self.performSegueWithIdentifier("ImagePostSegue", sender: self);
    }
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (hitEnd) {
            return;
        }
        for path: NSIndexPath in myCollectionView.indexPathsForVisibleItems() as Array<NSIndexPath> {
            if (path.row == loadedUpTo * MYPOST_LOAD_COUNT + endLoadCount - 1) {
                loadSet();
                return;
            }
        }
    }
}
