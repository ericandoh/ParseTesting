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

    //most recent notifications at start of array
    //var notifList: Array<InAppNotification?> = Array<InAppNotification?>();
    var notifList: Array<InAppNotification?> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
        //notifList = Array<InAppNotification>();
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 60.0;
    }
    
    override func viewDidAppear(animated: Bool) {
        //notifList = Array<InAppNotification>();
        //NSLog("Populating notifs")
        populateNotifs();
        self.tableView.reloadData();    //is this needed
    }
    
    func populateNotifs() {
       
        ServerInteractor.getNotifications(self);
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

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return notifList.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        
        let cell: UserTextTableViewCell = tableView!.dequeueReusableCellWithIdentifier("NotifCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        
        var temp = indexPath!.row;
        
        
        var member: InAppNotification = notifList[temp]! as InAppNotification;
        
        if (member.type == NotificationType.IMAGE_POST.toRaw()) {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.toRaw()) {
            cell.extraConfigurations(member.getSender(), message: member.messageString, enableFriending: true, sender: self)
        }
        else {
            cell.extraConfigurations(nil, message: member.messageString, enableFriending: false, sender: self)
        }
    
        
        //cell.textLabel.text = member.messageString;
        

        
        /*let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("NotifCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        var temp = indexPath!.row;
        
        
        var member: InAppNotification = notifList[temp] as InAppNotification;
        
        
        cell.textLabel.text = member.messageString;*/
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var temp = indexPath.row;
        
        var member: InAppNotification = notifList[temp]! as InAppNotification;

        if (member.type == NotificationType.IMAGE_POST.toRaw()) {
            member.getImagePost().fetchIfNeededInBackgroundWithBlock({(obj: PFObject!, error: NSError!) in
                if (error == nil) {
                    var imgBuffer = CustomImageBuffer(disableOnAnon: false, user: nil, owner: NOTIF_OWNER);
                    var onlyImagePost = ImagePostStructure.dequeueImagePost(obj);
                    imgBuffer.initialSetup4(nil, configureCellFunction: {(Int)->Void in }, alreadyLoadedPosts: [onlyImagePost]);
                    var newHome = self.storyboard.instantiateViewControllerWithIdentifier("Home") as HomeFeedController;
                    newHome.syncWithImagePostDelegate(imgBuffer, selectedAt: 0);
                    self.navigationController.pushViewController(newHome, animated: true);
                }
                else {
                    NSLog("App Notification object couldn't be found");
                }
                });
            //self.performSegueWithIdentifier("ImagePostSegue", sender: self);
        }
        else if (member.type == NotificationType.FOLLOWER_NOTIF.toRaw()) {
            //self.performSegueWithIdentifier("FriendRequestSegue", sender: self);
            if (self.navigationController != nil) {
                var friend = FriendEncapsulator.dequeueFriendEncapsulator(member.friendName);
                var nextBoard : UIViewController = self.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                self.navigationController.pushViewController(nextBoard, animated: true);
            }
        }
        else if (member.type == NotificationType.PLAIN_TEXT.toRaw()) {
            self.performSegueWithIdentifier("DefaultNotifSegue", sender: self);
        }
       /* else {
            if (member.type == NotificationType.FRIEND_ACCEPT.toRaw()) {
                member.personalObj!.deleteInBackground()
            }
        
        }*/
    }
        
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var id: String = segue!.identifier;
        
        let temp: Int = self.tableView.indexPathForSelectedRow().row;
        
        let notifObj: InAppNotification = notifList[temp]!;
        
        /*if (id == "ImagePostSegue") {
            var destination = segue!.destinationViewController as ImagePostNotifViewController;
            destination.receiveNotifObject(notifObj);
        }*/
        /*else if (id == "FriendRequestSegue") {
            var destination = segue!.destinationViewController as FriendRequestViewController;
            destination.receiveNotifObject(notifObj);
        }*/
        if (segue!.destinationViewController is SingleNotifViewController) {
            var destination = segue!.destinationViewController as SingleNotifViewController;
            destination.receiveNotifObject(notifObj);
        }
    }

}
