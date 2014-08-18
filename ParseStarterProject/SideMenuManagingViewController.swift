//
//  SideMenuManagingViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/24/14.
//
//

import UIKit

class SideMenuManagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var contentArea: UIView!
    @IBOutlet var sideView: UIView!
    @IBOutlet var sideTableView: UITableView!
    @IBOutlet var outOfMenuButton: UIButton!
    var viewControllerDictionary: Dictionary<String, UIViewController> = [:];
    var currentlyShowing: String = "";
    var menuOpen: Bool = true;
    
    var suppressMenu: Bool = false;
    
    var needRemove: Array<UIViewController> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        menuOpen = false;
        var x = self.sideView.center.x - CGFloat(BAR_WIDTH);
        var y = self.sideView.center.y;
        var point = CGPoint(x: x, y: y);
        sideView.center = point;
        outOfMenuButton.hidden = true;
        outOfMenuButton.alpha = 0;
        displayContentController(SIDE_MENU_ITEMS[0]);
        
        var toolbar = UIToolbar(frame: sideView.frame);
        toolbar.barStyle = UIBarStyle.Black;
        toolbar.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        //toolbar.barTintColor = UIColor.blackColor();
        self.sideView.insertSubview(toolbar, atIndex: 0);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    /*@IBAction func buttonOne(sender: AnyObject) {
        displayContentController("White");
    }*/
    
    @IBAction func swiped(sender: UISwipeGestureRecognizer) {
        var location: CGPoint = sender.locationInView(self.view);
        if (location.x <= CGFloat(TRIGGER_BAR_WIDTH)) {
            self.openMenu();
        }
    }
    @IBAction func swipeBack(sender: UISwipeGestureRecognizer) {
        hideSideBar();
    }
    @IBAction func clickOutOfMenu(sender: UIButton) {
        if (!menuOpen) {
            //this button should be hidden
            outOfMenuButton.hidden = true;
            outOfMenuButton.alpha = 0;
        }
        else {
            hideSideBar();
        }
    }
    
    @IBAction func topPartTouched(sender: UIButton) {
        if (!menuOpen) {
            //this button should be hidden
            outOfMenuButton.hidden = true;
            outOfMenuButton.alpha = 0;
        }
        else {
            hideSideBar();
        }
    }
    
    func openHome() {
        displayContentController(SIDE_MENU_ITEMS[0]);
    }
    func setSuppressed(suppressed: Bool) {
        suppressMenu = suppressed;
    }
    
    func openMenu() {
        if (menuOpen) {
            NSLog("Menu is already open what")
            return;
        }
        if (suppressMenu) {
            //Opening menu is suppressed;
            return;
        }
        menuOpen = true;
        outOfMenuButton.hidden = false;
        /*
        viewControllerDictionary[currentlyShowing] => current view controller, if you want to manipulate it
        */
        var x = self.sideView.center.x + CGFloat(BAR_WIDTH);
        var y = self.sideView.center.y;
        var point = CGPoint(x: x, y: y);
        self.sideView.hidden = false;
        self.view.bringSubviewToFront(self.outOfMenuButton);
        self.view.bringSubviewToFront(self.sideView);
        self.sideTableView.userInteractionEnabled = true;
        self.sideTableView.reloadData();
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            ()->Void in
            self.sideView.center = point;
            self.outOfMenuButton.alpha = SIDE_MENU_DIM;
            }, completion: {
                (success: Bool)->Void in
                self.view.bringSubviewToFront(self.sideView);
            });
    }
    func hideSideBar() {
        hideSideBar({(success: Bool)->Void in });
    }
    func hideSideBar(completions: (Bool)->Void) {
        if (menuOpen) {
            var x = self.sideView.center.x - BAR_WIDTH;
            var y = self.sideView.center.y;
            var point = CGPoint(x: x, y: y);
            self.sideTableView.userInteractionEnabled = false;
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                ()->Void in
                self.sideView.center = point;
                self.outOfMenuButton.alpha = 0;
                }, completion: {(success: Bool)->Void in
                    self.menuOpen = false;
                    self.outOfMenuButton.hidden = true;
                    completions(success);
                });
        }
        else {
            completions(true);
        }
    }
    //selects cell in our table and then switches
    func displayContentController(contentString: String) {
        suppressMenu = false;
        var selectedRow = -1;
        if let selectedIndex = sideTableView.indexPathForSelectedRow() {
            selectedRow = sideTableView.indexPathForSelectedRow().row;
        }
        var indexInArray = find(SIDE_MENU_ITEMS, contentString);
        
        if (indexInArray != selectedRow) {
            sideTableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexInArray!), animated: false, scrollPosition: UITableViewScrollPosition.None)
            /*var currentCell = sideTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexInArray));
            currentCell.selected = false;*/
            
        }
        
        displayContent(contentString);
    }
    //switches over to correct context
    func displayContent(contentString: String) {
        
        var previouslyShowing = currentlyShowing;
        currentlyShowing = contentString;
        self.sideTableView.reloadData();
        var refreshingHome: Bool = false;
        if (contentString == previouslyShowing) {
            if (SIDE_MENU_ITEMS[INDEX_OF_HOME] == contentString) {
                refreshingHome = true;
            }
            else {
                hideSideBar({(success: Bool)->Void in });
                return;
            }
        }
        
        var content: UIViewController;
        var old: UIViewController?;
        if (contains(self.viewControllerDictionary.keys, contentString)) {
            content = self.viewControllerDictionary[contentString]!;
            if (content is UINavigationController) {
                (content as UINavigationController).popToRootViewControllerAnimated(false);
            }
            if (refreshingHome) {
                old = self.viewControllerDictionary[contentString];
                content = self.storyboard.instantiateViewControllerWithIdentifier(contentString) as UIViewController;
                //setContentConstraints(content)
                self.viewControllerDictionary[contentString] = content;
            }
        }
        else {
            if ((ServerInteractor.isAnonLogged()) && ((contentString == "Upload") || (contentString == "FindFriends"))) {
                content = self.storyboard.instantiateViewControllerWithIdentifier("Anon") as UIViewController;
            } else {
                content = self.storyboard.instantiateViewControllerWithIdentifier(contentString) as UIViewController;
            }
            //setContentConstraints(content);
            self.viewControllerDictionary[contentString] = content;
        }
        content.view.alpha = 0;
        hideSideBar({
            (success: Bool)->Void in
            
            
            
            /*self.addChildViewController(content);
            content.view.frame = self.contentArea.frame;
            self.view.addSubview(content.view);
            content.didMoveToParentViewController(self);*/
            
            if (self.viewControllerDictionary[previouslyShowing] == nil) {
                self.addChildViewController(content);
                //content.view.frame = self.contentArea.frame;
                self.contentArea.addSubview(content.view);    //new
                self.setContentConstraints(content);
                //self.view.addSubview(content.view);
                content.didMoveToParentViewController(self);
                UIView.animateWithDuration(0.3, animations: {()->Void in
                    content.view.alpha = 1;
                    });
            }
            else {
                if (old == nil) {
                    old = self.viewControllerDictionary[previouslyShowing]!;
                }
                
                old!.willMoveToParentViewController(nil);
                self.addChildViewController(content);
                //content.view.frame = self.contentArea.frame;
                self.contentArea.addSubview(content.view);    //new
                self.setContentConstraints(content);
                //self.view.addSubview(content.view);
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {()->Void in
                    content.view.alpha = 1;
                    old!.view.alpha = 0;
                    }, completion: {(success: Bool)->Void in
                        old!.removeFromParentViewController();
                        content.didMoveToParentViewController(self);
                        old!.view.removeFromSuperview();
                    });
            }
            if (self.needRemove.count > 0) {
                for removeVC in self.needRemove {
                    removeVC.willMoveToParentViewController(nil);
                    removeVC.removeFromParentViewController();
                    removeVC.view.removeFromSuperview();
                }
            }
            
            //self.currentlyShowing = contentString;
            self.sideView.hidden = true;
            self.view.layoutIfNeeded();
            self.view.layoutSubviews();
            });
    }
    func hideContentController(content: UIViewController) {
        content.willMoveToParentViewController(nil);
        content.view.removeFromSuperview();
        content.removeFromParentViewController();
    }
    //deprecated
    func cycleFromViewController(oldC: UIViewController, toViewController newC: UIViewController) {
        NSLog("Something is calling a deprecated method, please fix");
        /*oldC.willMoveToParentViewController(nil);
        self.addChildViewController(newC);
        //newC.view.frame = new frame
        //CGRect endFrame = old view frame
        newC.view.frame = self.contentArea.frame;
        self.transitionFromViewController(oldC, toViewController: newC, duration: 0.25, options: UIViewAnimationOptions.TransitionNone,
            animations: {()->Void in
                //newC.view.frame = oldC.view.frame;
                newC.view.frame = self.contentArea.frame;
                //oldC.view.frame = endFrame;
            }, completion: {(finished: Bool)->Void in
                oldC.removeFromParentViewController();
                newC.didMoveToParentViewController(self);
                
                oldC.view.removeFromSuperview();
                
                
            })*/
    }
    //resets a window to the start, by forcing it to create a new instance when switched to
    //this does NOT switch windows
    func resetWindow(contentString: String) {
        if (self.viewControllerDictionary[contentString] != nil) {
            needRemove.append(self.viewControllerDictionary[contentString]!);
        }
        var content = self.storyboard.instantiateViewControllerWithIdentifier(contentString) as UIViewController;
        //setContentConstraints(content);
        self.viewControllerDictionary[contentString] = content;
    }
    func setContentConstraints(controller: UIViewController) {
        //let viewsDictionary: NSDictionary = ["view": self.contentArea]
        //var verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view(==40)]|", options: NSLayoutFormatOptions.fromRaw(0)!, metrics: nil, views: viewsDictionary);
        //var horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view(==40)]|", options: NSLayoutFormatOptions.fromRaw(0)!, metrics: nil, views: viewsDictionary);
        //var horizontalConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: FULLSCREEN_WIDTH);
        //var verticalConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: TRUE_FULLSCREEN_HEIGHT);
        //controller.view.addConstraint(verticalConstraint);
        //controller.view.addConstraint(horizontalConstraint);
        //controller.view.setNeedsLayout();
        //controller.view.setNeedsUpdateConstraints();
        var myConstraints = controller.view.constraints();
        controller.view.removeConstraints(myConstraints);
        var topConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0);
        var leadingConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0);
        var trailingConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0);
        var bottomConstraint = NSLayoutConstraint(item: controller.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentArea, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0);
        self.contentArea.addConstraint(topConstraint);
        self.contentArea.addConstraint(leadingConstraint);
        self.contentArea.addConstraint(trailingConstraint);
        self.contentArea.addConstraint(bottomConstraint);
        controller.view.addConstraints(myConstraints);
    }
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return SIDE_MENU_ITEMS.count;
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: SideMenuTableViewCell = tableView!.dequeueReusableCellWithIdentifier("SideMenuItem", forIndexPath: indexPath) as SideMenuTableViewCell
        
        //cell.textLabel.text = SIDE_MENU_NAMES[indexPath.row];
        cell.titleLabel.text = SIDE_MENU_NAMES[indexPath.row];
        
        cell.titleLabel.font = UIFont(name: "HelveticaNeueLTPro-Lt", size: 20.0)
        
        //cell.imageView.image = SIDE_MENU_IMAGES[indexPath.row];
        cell.iconImageView.image = SIDE_MENU_IMAGES[indexPath.row];
        //cell.imageView.frame = CGRectMake(0, 0, 40, 40);
        
        //var backColor = UIColor(red: SIDE_MENU_BACK_RED, green: SIDE_MENU_BACK_GREEN, blue: SIDE_MENU_BACK_BLUE, alpha: 1.0);
        
        var transparentBackgroundView = UIView();
        transparentBackgroundView.backgroundColor = SIDE_MENU_BACK_COLOR;
        transparentBackgroundView.alpha = CGFloat(SIDE_MENU_OPACITIES[indexPath.row]) / DAMPENING_CONSTANT;
        
        //transparentBackgroundView.alpha = 0.1;
        
        //cell.alpha = CGFloat(SIDE_MENU_OPACITIES[indexPath.row]);
        //cell.backgroundColor = backColor;
        cell.backgroundView = transparentBackgroundView;
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        
        //var label: UILabel = UILabel(frame: CGRectMake(0, 0, 40, 40));
        
        if (SIDE_MENU_ITEMS[indexPath.row] == currentlyShowing) {
            cell.titleLabel.textColor = UIColor(white: 1.0, alpha: 0.9);
            cell.iconImageView.alpha = 0.9;
            cell.numberCounter.textColor = UIColor(white: 1.0, alpha: 0.9);
        }
        else {
            cell.titleLabel.textColor = UIColor(white: 1.0, alpha: 0.4);
            cell.iconImageView.alpha = 0.4;
            cell.numberCounter.textColor = UIColor(white: 1.0, alpha: 0.4);
        }
        if (indexPath.row == INDEX_OF_NOTIF) {
            cell.numberCounter.textAlignment = NSTextAlignment.Center;
            ServerInteractor.getNumUnreadNotifications({
                (result: Int) in
                cell.numberCounter.text = String(result);
            })
            //cell.contentView.addSubview(label);
        }
        else {
            cell.numberCounter.text = "";
        }
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var boardName = SIDE_MENU_ITEMS[indexPath.row];
        displayContent(boardName);
    }
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return SIDE_MENU_TABLE_CELL_HEIGHT;
    }
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
