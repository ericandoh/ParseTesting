//
//  FriendTableViewController.swift
//  ParseStarterProject
//
//  View your friends in a table
//
//  Created by Eric Oh on 7/1/14.
//
//

class FriendTableViewController: UITableViewController {

    var srcFriend: FriendEncapsulator?;
    
    var friendList: Array<FriendEncapsulator?> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
        //refetch friends from serverside
        friendList = ServerInteractor.getFriends(); //--> change this to getFriends(srcFriend)
        self.tableView.reloadData();
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
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as UITableViewCell
        // Configure the cell...
        
        var temp = indexPath!.row;
        
        if(temp == 0) {
            //cell is marked with a plus
            cell.textLabel.text = "Add friend";
        }
        else {
            cell.textLabel.text = friendList[temp - 1]!.getName({self.tableView.reloadData()});
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return indexPath!.row == 0; //can only edit at row 0, and at all times
    }
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            let alert: UIAlertController = UIAlertController(title: "Add Friend", message: "Enter your friend's username", preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler(nil);
            alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                //NSLog("Clicked stuff \(alert.textFields[0].text)");
                ServerInteractor.postFriendRequest(alert.textFields[0].text, controller: self);
                }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                //canceled
                }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //handle segueing to friend profile pages, if have time
            
            //issues! work
            
            //below is temporary; please remake
            //self.performSegueWithIdentifier("FriendViewSegue", sender: self);
            
            //make a user
            let index: Int = self.tableView.indexPathForSelectedRow().row - 1;
            
            //I "think" this makes a copy from storyboard, lets hope I am right.
            var nextBoard : UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
            
            (nextBoard as SettingsViewController).receiveUserInfo(friendList[index]!);
            
            self.navigationController.pushViewController(nextBoard, animated: true);
            
        }
    }
    func notifyFailure(message: String) {
        
        var alert = UIAlertController(title: "Uh oh!", message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView?, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath?) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView?, moveRowAtIndexPath fromIndexPath: NSIndexPath?, toIndexPath: NSIndexPath?) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView?, canMoveRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        
        if (segue!.identifier == "FriendViewSegue") {
            let index: Int = self.tableView.indexPathForSelectedRow().row - 1;
        
            var targetCont = segue!.destinationViewController as FriendSingleViewController;
            targetCont.receiveUserInfo(friendList[index]!);
        }
    }*/
    

}
