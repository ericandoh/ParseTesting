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
        tableView.alwaysBounceVertical = false;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.reloadData();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopLooks.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopLookCell", forIndexPath: indexPath) as UITableViewCell;

        cell.textLabel!.text = shopLooks[indexPath.row].title;
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        cell.textLabel!.textColor = UIColor.whiteColor()
        //cell.textLabel.font = TABLE_CELL_FONT;
        cell.textLabel!.font = UIFont(name: "System", size: 16.0);

        //BELOW IS A BUG! >:(
        //cell.separatorInset = UIEdgeInsetsZero;
        //cell.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
        var needMakeSeparator: Bool = true;
        for smallView in cell.contentView.subviews {
            if ((smallView as UIView).tag == 60253) {
                needMakeSeparator = false;
                break;
            }
        }
        if (needMakeSeparator) {
            var view = UIView(frame: CGRectMake(0, cell.bounds.height - 1, cell.bounds.width, 1));
            //view.backgroundColor = tableView.separatorColor;
            view.backgroundColor = UIColor(white: 1.0, alpha: 0.4);
            view.tag = 60253;
            cell.contentView.addSubview(view);
        }
        
        var forwardImg = UIImageView(image: FORWARD_ICON);
        
        forwardImg.frame = CGRectMake(0, 0, 20, 20)
        
        cell.accessoryView = forwardImg;
        
        /*let viewsDictionary: NSDictionary = ["view": cell.accessoryView.superview!]
        var verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view(==40)]|", options: NSLayoutFormatOptions.fromRaw(0)!, metrics: nil, views: viewsDictionary);
        var horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view(==40)]|", options: NSLayoutFormatOptions.fromRaw(0)!, metrics: nil, views: viewsDictionary);
        forwardImg.addConstraints(verticalConstraints);
        forwardImg.addConstraints(horizontalConstraints);*/
        
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var urlString = shopLooks[indexPath.row].urlLink;
        //NSLog("Opening" + urlString);
        var urlToOpen = NSURL(string: urlString)!;
        if (UIApplication.sharedApplication().canOpenURL(urlToOpen)) {
            UIApplication.sharedApplication().openURL(urlToOpen);
        }
        else {
            if (!urlString.hasPrefix("http://") && !urlString.hasPrefix("https://")) {
                urlString = "http://"+urlString;
                urlToOpen = NSURL(string: urlString)!;
                if (UIApplication.sharedApplication().canOpenURL(urlToOpen)) {
                    UIApplication.sharedApplication().openURL(urlToOpen);
                }
                else {
                    CompatibleAlertViews.makeNotice("URL Invalid", message: "URL for this ShopTheLook is invalid!\n\nURL: "+urlString, presenter: owner)
                    /*let alert: UIAlertController = UIAlertController(title: "URL Invalid", message: "URL for this ShopTheLook is invalid!\n\nURL: "+urlString, preferredStyle: UIAlertControllerStyle.Alert);
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        //canceled
                        }));
                    owner.presentViewController(alert, animated: true, completion: nil)*/
                }
            }
        }
    }
}
