//
//  FriendTableViewController.swift
//  ParseStarterProject
//
//  View your friends in a table
//
//  Created by Eric Oh on 7/1/14.
//
//

class FriendTableViewController: UITableViewController, UITableViewDataSource  {

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
        //self.tableView(self.tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: <#NSIndexPath#>)
        //self.tableView.allowsSelectionDuringEditing = true
        //self.setEditing(false, animated: false);
        setEditing(true, animated: true)
        
        //tableView.setEditing(true, animated: true)
        //tableView.editing = true;
        
        //refetch friends from serverside
        //self.tableView.reloadData();
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
        //self.setEditing(false, animated: false)
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
        //cell.editingStyle = UITableViewCellEditingStyle.Delete;
        
        return cell
    }
    
    /*@IBAction func deleteFriendz(sender: UIPanGestureRecognizer) {
        var translation: CGPoint = sender.translationInView(self.view)
        
        var location: CGPoint = sender.locationInView(tableView)
        
        var indexRow = self.tableView.indexPathForRowAtPoint(location)
        
        var cell = tableView.cellForRowAtIndexPath(indexRow)
        
        var cellPosition: CGPoint = cell.center
        
        cellPosition.x += (translation.x / 10.0)
        
        //NSLog(translation.x)
        
        cell.center = cellPosition
            }*/
    
    /*func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) {
        
        return true;
    }*/
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false;
        }
        return true;
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //super.tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath);
        NSLog("Commiting edits at \(indexPath.row)")
        //self.tableView.beginUpdates();
        //self.setEditing(true, animated: true)
        if (editingStyle == UITableViewCellEditingStyle.Delete && indexPath.row != 0) {
            NSLog("Deleting!");
            //let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as UITableViewCell
            //cell.textLabel.text = ""
            
            //removeObjectAtIndex(indexPath.row)
            
            
            var index = indexPath.row - 1;
            
            NSLog("\(friendList.count)")
            ServerInteractor.removeFriend(friendList[index]!.getName({}), isHeartBroken: false)
            
            friendList.removeAtIndex(indexPath.row - 1)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)

            NSLog("it comes this far")
            //tableView.reloadData();
        }
        //self.tableView.endUpdates();
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return indexPath!.row == 0; //can only edit at row 0, and at all times
    }
    */
    override func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //super.tableView(tableView, didSelectRowAtIndexPath: indexPath);
        NSLog("Selecting");
        if (indexPath.row == 0) {
            NSLog("---")
            NSLog("\(self.editing)");
            NSLog("\(self.tableView(self.tableView, canEditRowAtIndexPath:NSIndexPath(forRow: 1, inSection: 0  ) ))")
            //self.setEditing(!self.editing, animated: true);
            NSLog("\(self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0  )).editingStyle.toRaw())")
            NSLog("\(self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0  )).editingStyle.toRaw())")
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
