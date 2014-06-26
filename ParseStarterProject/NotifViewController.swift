//
//  NotifViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

class NotifViewController: UITableViewController {

    //most recent notifications at start of array
    var notifList: NSMutableArray?;
    
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
        
        //notifList = Array<InAppNotification>();
        notifList = NSMutableArray();
        populateNotifs();
    }
    
    func populateNotifs() {
        //(BACKEND)
        //populate your notif list here
        notifList!.addObject(InAppNotification(message: "Thank you for joining us!"));
        notifList!.addObject(InAppNotification(message: "Your last picture got no likes! :D"));
        notifList!.addObject(InAppNotification(message: "No one likes you :("));
        NSLog("We have \(notifList!.count) things in our list now!");
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
        if notifList {
            return notifList!.count
        }
        return 0;
    }

    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("NotifCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        
        var temp = indexPath!.row;
        
        var member: InAppNotification = notifList![temp] as InAppNotification;
        
        cell.textLabel.text = member.messageString;
        
        return cell
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

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
