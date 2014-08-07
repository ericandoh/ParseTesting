//
//  FriendTableViewController.swift
//  ParseStarterProject
//
//  View your friends in a table
//
//  Created by Eric Oh on 7/1/14.
//
//

class FriendTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate  {

    var srcFriend: FriendEncapsulator?;
    
    var friendList: Array<FriendEncapsulator?> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        friendList = ServerInteractor.getFriends(srcFriend!); //--> change this to getFriends(srcFriend)

        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        self.tableView.allowsSelectionDuringEditing = true
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);

        setEditing(true, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveMasterFriend(friend: FriendEncapsulator) {
        srcFriend = friend;
    }
    
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        // last cell is always editable
        return friendList.count + 1;
    }
    
    override func tableView(tableView: UITableView!, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath!) -> String! {
        return "Unfollow"
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as UITableViewCell
        // Configure the cell...
        
        var temp = indexPath!.row;
        
        if(temp == 0) {
            //cell is marked with a plus
            cell.textLabel.text = "Add follower";
        }
        else {
            cell.textLabel.text = friendList[temp - 1]!.getName({self.tableView.reloadData()});
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false;
        }
        return true;
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete && indexPath.row != 0) {
            
            var index = indexPath.row - 1;
            
            NSLog("\(friendList.count)")
            ServerInteractor.removeFriend(friendList[index]!.getName({}), isHeartBroken: false)
            
            friendList.removeAtIndex(indexPath.row - 1)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

        }
    }
    
    override func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            let alert: UIAlertController = UIAlertController(title: "Add Follower", message: "Enter your friend's username", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler(nil);
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                ServerInteractor.postFollowerNotif((alert.textFields[0] as UITextField).text, controller: self);
                ServerInteractor.addAsFriend((alert.textFields[0] as UITextField).text);
                ServerInteractor.addAsFollower((alert.textFields[0] as UITextField).text)
                //ServerInteractor.findFollowing((alert.textFields[0] as UITextField).text)
                }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                //canceled
                }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //handle segueing to friend profile pages, if have time
            
            //issues! work
            
            //make a user
            let index: Int = self.tableView.indexPathForSelectedRow().row - 1;
            
            //I "think" this makes a copy from storyboard, lets hope I am right.
            var nextBoard : UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            
            (nextBoard as UserProfileViewController).receiveUserInfo(friendList[index]!);
            
            self.navigationController.pushViewController(nextBoard, animated: true);
            
        }
    }
    
    
    
    func notifyFailure(message: String) {
        
        var alert = UIAlertController(title: "Uh oh!", message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
