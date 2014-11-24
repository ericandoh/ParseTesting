//
//  NotifViewController.swift
//  ParseStarterProject
//
//  View your notifications when prompted
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

let NOTIF_OWNER = "NOTIF"

class NotifViewController: UITableViewController {

    @IBOutlet weak var backButton: UIButton!
    //most recent notifications at start of array
    //var notifList: Array<InAppNotification?> = Array<InAppNotification?>();
    var notifList: Array<InAppNotification?> = [];
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if (self.navigationController!.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController!.interactivePopGestureRecognizer.enabled = false;
        }
        //notifList = Array<InAppNotification>();
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationController!.navigationBar.topItem!.title = "Notifications";
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        var custView: UIView = UIView()
        custView.backgroundColor = UIColor.blackColor();
        //let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        //effectView.frame = CGRect(x: 0, y: 0, width: FULLSCREEN_WIDTH, height: TRUE_FULLSCREEN_HEIGHT)
        //custView.addSubview(effectView)
        //let gradientView: UIImageView = UIImageView(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT))
        //gradientView.image = GRADIENT_IMG
        //view.addSubview(gradientView)
        self.tableView.backgroundView = custView
        //self.view.insertSubview(custView, atIndex: 0);
        
        if (ServerInteractor.isAnonLogged()) {
            var imageView: BlurringDarkView = BlurringDarkView(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT));
            imageView.setImageAndBlur(DEFAULT_USER_ICON);
            //imageView.image = DEFAULT_USER_ICON;
            custView.insertSubview(imageView, atIndex: 0)
        }
        else {
            var mainUser = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser().username)
            mainUser.fetchImage({(image: UIImage)->Void in
                var imageView: BlurringDarkView = BlurringDarkView(frame: CGRectMake(0, 0, FULLSCREEN_WIDTH, TRUE_FULLSCREEN_HEIGHT));
                imageView.setImageAndBlur(image);
                //imageView.image = image
                custView.insertSubview(imageView, atIndex: 0)
            });
        }
        
        
        //self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0;
        
        var refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshNeeded:", forControlEvents: UIControlEvents.ValueChanged);
        self.refreshControl = refreshControl;
        //tableView.insertSubview(self.refreshControl, aboveSubview: custView)
        //custView.addSubview(refreshControl);
        //tableView.bringSubviewToFront(refreshControl);
        
        self.refreshControl!.layer.zPosition = self.tableView.backgroundView!.layer.zPosition + CGFloat(1);
        //self.refreshControl!.layer.zPosition = self.tableView.backgroundView.layer.zPosition + CGFloat(1);
        
        
        //self.tableView.backgroundView.layer.zPosition -= 1;
    }
    
    override func viewDidAppear(animated: Bool) {
        //notifList = Array<InAppNotification>();
        //NSLog("Populating notifs")
        populateNotifs();
        //self.tableView.reloadData();    //is this needed
    }
    
    @IBAction func backPress(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count == 1) {
                //this is the only vc on the stack - move to menu
                (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
            }
            else {
                //(self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu()
                self.navigationController!.popViewControllerAnimated(true);
            }
        }
    }
    
    
    func populateNotifs() {
       
        ServerInteractor.getNotifications(self);
    }
    func populateNotifs(refresher: UIRefreshControl) {
        ServerInteractor.getNotifications(self, refreshControl: refresher);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return notifList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UserTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("NotifCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        
        var temp = indexPath.row;
        
        
        var member: InAppNotification = notifList[temp]! as InAppNotification;
        
        if (member.wasReadBefore()) {
            cell.setTextFieldLighter();
        }
        else {
            cell.setTextFieldNormal();
        }
        
        if (member.type == NotificationType.IMAGE_POST_LIKE.rawValue) {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        else if (member.type == NotificationType.IMAGE_POST_COMMENT.rawValue) {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        else if (member.type == "ImagePost") {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.rawValue) {
            cell.extraConfigurations(member.getSender(), message: member.messageString, enableFriending: true, sender: self)
        }
        else {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        
        
        cell.descriptionBox.otherAction = {
            () in
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None);
            self.pressedNotifAt(indexPath);
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int = indexPath.row;
        
        var member: InAppNotification = notifList[index]! as InAppNotification;
        var recHeight: CGFloat = CGFloat(tableView.estimatedRowHeight);
        
        if (member.type == NotificationType.IMAGE_POST_LIKE.rawValue) {
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(nil, message: member.messageString, enableFriending: false);
        }
        else if (member.type == NotificationType.IMAGE_POST_COMMENT.rawValue) {
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(nil, message: member.messageString, enableFriending: false);
        }
        else if (member.type == "ImagePost") {
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(nil, message: member.messageString, enableFriending: false);
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.rawValue) {
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(member.getSender(), message: member.messageString, enableFriending: true);
        }
        else {
            recHeight = UserTextTableViewCell.getDesiredHeightForCellWith(nil, message: member.messageString, enableFriending: false);
        }
        return recHeight;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        pressedNotifAt(indexPath);
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    func pressedNotifAt(indexPath: NSIndexPath) {
        var temp = indexPath.row;
        
        var member: InAppNotification = notifList[temp]! as InAppNotification;
        
        if (member.type == NotificationType.IMAGE_POST_LIKE.rawValue || member.type == NotificationType.IMAGE_POST_COMMENT.rawValue || member.type == "ImagePost") {
            member.getImagePost().fetchIfNeededInBackgroundWithBlock({(obj: PFObject!, error: NSError!) in
                if (error == nil) {
                    var imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: NOTIF_OWNER);
                    var onlyImagePost = ImagePostStructure.dequeueImagePost(obj);
                    imgBuffer.initialSetup4(nil, configureCellFunction: {(Int)->Void in }, alreadyLoadedPosts: [onlyImagePost]);
                    var newHome = self.storyboard!.instantiateViewControllerWithIdentifier("Home") as HomeFeedController;
                    newHome.syncWithImagePostDelegate(imgBuffer, selectedAt: 0);
                    self.navigationController!.pushViewController(newHome, animated: true);
                }
                else {
                    NSLog("App Notification object couldn't be found");
                }
            });
            //self.performSegueWithIdentifier("ImagePostSegue", sender: self);
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.rawValue) {
            //self.performSegueWithIdentifier("FriendRequestSegue", sender: self);
            if (self.navigationController != nil) {
                var friend = FriendEncapsulator.dequeueFriendEncapsulator(member.friendName);
                var nextBoard : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                self.navigationController!.pushViewController(nextBoard, animated: true);
            }
        }
        else if (member.type == NotificationType.PLAIN_TEXT.rawValue) {
            //self.performSegueWithIdentifier("DefaultNotifSegue", sender: self);
        }
        /* else {
        if (member.type == NotificationType.FRIEND_ACCEPT.rawValue) {
        member.personalObj!.deleteInBackground()
        }
        
        }*/
    }
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var id: String = segue.identifier!;
        
        let temp: Int = self.tableView.indexPathForSelectedRow()!.row;
        
        let notifObj: InAppNotification = notifList[temp]!;
        
        /*if (id == "ImagePostSegue") {
            var destination = segue!.destinationViewController as ImagePostNotifViewController;
            destination.receiveNotifObject(notifObj);
        }*/
        /*else if (id == "FriendRequestSegue") {
            var destination = segue!.destinationViewController as FriendRequestViewController;
            destination.receiveNotifObject(notifObj);
        }*/
        if (segue.destinationViewController is SingleNotifViewController) {
            var destination = segue.destinationViewController as SingleNotifViewController;
            destination.receiveNotifObject(notifObj);
        }
    }
    func refreshNeeded(sender: UIRefreshControl) {
        populateNotifs(sender);
        //self.tableView.reloadData();    //is this needed
    }

}
