//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  View Controller for the User Profile Page of the current user
//  (not actually settings!!!)
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var userNameLabel: UILabel
    @IBOutlet var logOffButton: UIButton
    @IBOutlet var settingsButton: UIButton
    @IBOutlet var myCollectionView: UICollectionView
    @IBOutlet var friendsButton: UIButton
    
    @IBOutlet var userIcon: UIImageView
    
    var mainUser: FriendEncapsulator?;
    
    //var loadCount: Int = MYPOST_LOAD_COUNT;
    //the posts I have loaded
    var loadedPosts: Array<ImagePostStructure?> = [];
    
    //how many sets I have loaded up to
    var loadedUpTo: Int = 0;
    
    //how many images are loaded in our last set (only valid when hitEnd = true)
    var endLoadCount: Int = 0;
    
    //set to true when I have already loaded in last set of stuff
    var hitEnd: Bool = false;
    
    /*init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        if (mainUser && mainUser!.username != ServerInteractor.getUserName()) {
            userNameLabel.text = mainUser!.getName({self.userNameLabel.text = self.mainUser!.getName({NSLog("Failed twice to fetch name")})});
            mainUser!.fetchImage({(image: UIImage)->Void in
                self.userIcon.image = image;
                });
            logOffButton.hidden = true;         //same as below
            settingsButton.hidden = true;       //we could make this so this points to remove friend or whatnot
        }
        else {
            if (ServerInteractor.isAnonLogged()) {
                userNameLabel.text = "Not logged in";
                logOffButton.setTitle("Sign In", forState: UIControlState.Normal)
                self.userIcon.image = DEFAULT_USER_ICON;
                friendsButton.hidden = true;
            }
            else {
                mainUser = ServerInteractor.getCurrentUser();
                // Do any additional setup after loading the view.
                userNameLabel.text = ServerInteractor.getUserName();
                mainUser!.fetchImage({(fetchedImage: UIImage)->Void in
                    self.userIcon.image = fetchedImage;
                    });
            }
        }
        //start fetching submission posts for user, for first set here
        loadedUpTo = 0;
        loadedPosts = [];
        if (!ServerInteractor.isAnonLogged()) {
            loadSet();
        }
        else {
            hitEnd = true;
            endLoadCount = 0;
        }
    }
    func receiveUserInfo(displayFriend: FriendEncapsulator) {
        mainUser = displayFriend;
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
        if (segue!.identifier) {
            if (segue!.identifier == "SeeFriendsSegue") {
                if (mainUser) {
                    (segue!.destinationViewController as FriendTableViewController).receiveMasterFriend(mainUser!);
                }
            }
        }
    }
    

    @IBAction func logOff(sender: UIButton) {
        if (!ServerInteractor.isAnonLogged()) {
            ServerInteractor.logOutUser();
        }
    }
    @IBAction func debugPurposeButton(sender: UIButton) {
        //Test1: Tries posting a notification
        ServerInteractor.postDefaultNotif("Test submission post");
        //lets also try adding to user field
    }
    func receiveNumQuery(size: Int) {
        if (size != MYPOST_LOAD_COUNT) {
            hitEnd = true;
            endLoadCount = size;
        }
        myCollectionView.reloadData();
    }
    func receiveImagePostWithImage(loaded: ImagePostStructure, index: Int) {
        //called by getSubmissions for when image at index x is loaded in...
        NSLog("Received image at index \(index)")
        var realIndex = index + ((loadedUpTo - 1) * MYPOST_LOAD_COUNT);
        loadedPosts[realIndex] = loaded;
        
        for path : AnyObject in myCollectionView.indexPathsForVisibleItems() {
            if ((path as NSIndexPath).row == realIndex) {
                var cell: SinglePostCollectionViewCell = myCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: realIndex, inSection: 0)) as SinglePostCollectionViewCell;
                //do stuff with cell
                configureCell(cell, index: realIndex);
            }
        }
    }
    //configures current cell at index with the appropriate post in loadedPosts
    //assumes post at index is already fetched from server
    func configureCell(cell: SinglePostCollectionViewCell, index: Int) {
        var post: ImagePostStructure = loadedPosts[index]!;
        //configure cell to set image here, etc.
        cell.postLabel.text = "Cell \(index)"
        cell.imageView.image = post.image;
    }
    func loadSet() {
        loadedUpTo += 1;
        loadedPosts += Array<ImagePostStructure?>(count: MYPOST_LOAD_COUNT, repeatedValue: nil);
        //start loading next set of MYPOST_LOAD_COUNT here
        //ServerInteractor.getSubmissions()...; with receiveNumQuery, receiveImagePostWithImage
        //broke here
        ServerInteractor.getSubmissions((loadedUpTo - 1) * MYPOST_LOAD_COUNT, loadCount: MYPOST_LOAD_COUNT, user: mainUser!, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
    }
    //----------------------collectionview methods------------------------------
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (hitEnd) {
            return (loadedUpTo - 1) * MYPOST_LOAD_COUNT + endLoadCount;
        }
        return loadedUpTo * MYPOST_LOAD_COUNT;
    }
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell: SinglePostCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCell", forIndexPath: indexPath) as SinglePostCollectionViewCell;
        
        if (loadedPosts[indexPath.row] != nil) {
            //load in cell
            configureCell(cell, index: indexPath.row)
        }
        else {
            //cell will get fetched, wait
        }
        
        return cell;
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        NSLog("Selected at \(indexPath!.row)");
    }
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (hitEnd) {
            return;
        }
        for path: NSIndexPath in myCollectionView.indexPathsForVisibleItems() as Array<NSIndexPath> {
            if (path.row == loadedUpTo * MYPOST_LOAD_COUNT - 1) {
                //need to load more
                loadSet();
                return;
            }
        }
    }
}
