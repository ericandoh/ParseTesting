//
//  ShopLookDelegate.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/30/14.
//
//

import UIKit

class ShopLookDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {

    var shopLooks: Array<ShopLook>;
    
    var owner: UIViewController;
    
    init(looks: Array<ShopLook>, owner: UIViewController) {
        self.shopLooks = looks;
        self.owner = owner;
    }
    func initialSetup(tableView: UITableView) {
        tableView.delegate = self;
        tableView.dataSource = self;
        if (shopLooks.count == 0) {
            tableView.hidden = true;
        }
        else {
            tableView.hidden = false;
        }
        tableView.reloadData();
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return shopLooks.count;
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopLook", forIndexPath: indexPath) as UITableViewCell;

        cell.textLabel.text = shopLooks[indexPath.row].title;
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var urlString = shopLooks[indexPath.row].urlLink;
        //NSLog("Opening" + urlString);
        var urlToOpen = NSURL(string: urlString);
        if (UIApplication.sharedApplication().canOpenURL(urlToOpen)) {
            UIApplication.sharedApplication().openURL(urlToOpen);
        }
        else {
            if (!urlString.hasPrefix("http://")) {
                urlString = "http://"+urlString;
                urlToOpen = NSURL(string: urlString);
                if (UIApplication.sharedApplication().canOpenURL(urlToOpen)) {
                    UIApplication.sharedApplication().openURL(urlToOpen);
                }
                else {
                    let alert: UIAlertController = UIAlertController(title: "URL Invalid", message: "URL for this ShopTheLook is invalid!\n\nURL: "+urlString, preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        //canceled
                        }));
                    owner.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
