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

class NotifViewController: UITableViewController {

    //most recent notifications at start of array
    var notifList: Array<InAppNotification?> = Array<InAppNotification?>();
    
    /*
    init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //NSLog("Resetting notif list")
        notifList = Array<InAppNotification>();
        //populateNotifs();
    }
    
    override func viewDidAppear(animated: Bool) {
        //notifList = Array<InAppNotification>();
        //NSLog("Populating notifs")
        populateNotifs();
        self.tableView.reloadData();    //is this needed
    }
    
    func populateNotifs() {
        //(BACKEND)
        //populate your notif list here
        //notifList.append(InAppNotification(message: "Thank you for joining us!"));
        //notifList.append(InAppNotification(message: "Your last picture got no likes! :D"));
        //notifList.append(InAppNotification(message: "No one likes you :("));
        //NSLog("We have \(notifList.count) things in our list now!");
        ServerInteractor.getNotifications(self);
        /*for index in 0..notifList.count {
            notifList[index]!.assignMessage(self)
        }*/
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
        //return NOTIF_COUNT;
        return notifList.count
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("NotifCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        var temp = indexPath!.row;
        
        //temp = notifList.count - 1 - temp;
        
        var member: InAppNotification = notifList[temp] as InAppNotification;
        
        
        //member.assignMessage();
        //modify below line so this happens AFTER message is loaded
        //NSLog("Retrieving message with message \(member.messageString) at row \(temp)")
        cell.textLabel.text = member.messageString;
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var temp = indexPath.row;
        
        var member: InAppNotification = notifList[temp] as InAppNotification;
        if (member.type == NotificationType.IMAGE_POST.toRaw()) {
            self.performSegueWithIdentifier("ImagePostSegue", sender: self);
        }
        else if (member.type == NotificationType.FRIEND_REQUEST.toRaw()) {
            self.performSegueWithIdentifier("FriendRequestSegue", sender: self);
        }
        else {
            self.performSegueWithIdentifier("DefaultNotifSegue", sender: self);
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView?, canEditRowAtIndexPath indexPath: NSIndexPath?) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

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

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var id: String = segue!.identifier;
        
        let temp: Int = self.tableView.indexPathForSelectedRow().row;
        
        let notifObj: InAppNotification = notifList[temp]!;
        
        if (id == "ImagePostSegue") {
            var destination = segue!.destinationViewController as ImagePostNotifViewController;
            destination.receiveNotifObject(notifObj);
        }
        else if (id == "FriendRequestSegue") {
            var destination = segue!.destinationViewController as FriendRequestViewController;
            destination.receiveNotifObject(notifObj);
        }
        else {
            var destination = segue!.destinationViewController as SingleNotifViewController;
            destination.receiveNotifObject(notifObj);
        }
    }

}
