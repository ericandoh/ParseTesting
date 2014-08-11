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
            outOfMenuButton.hidden = true;
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
        
        if (contentString == previouslyShowing) {
            hideSideBar({(success: Bool)->Void in });
            return;
        }
        
        var content: UIViewController;
        if (contains(self.viewControllerDictionary.keys, contentString)) {
            content = self.viewControllerDictionary[contentString]!;
            if (content is UINavigationController) {
                (content as UINavigationController).popToRootViewControllerAnimated(false);
            }
        }
        else {
            
            if ((ServerInteractor.isAnonLogged()) && ((contentString == "Upload") || (contentString == "FindFriends"))) {
                content = self.storyboard.instantiateViewControllerWithIdentifier("Anon") as UIViewController;
            } else {
                content = self.storyboard.instantiateViewControllerWithIdentifier(contentString) as UIViewController;
            }
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
                content.view.frame = self.contentArea.frame;
                self.view.addSubview(content.view);
                content.didMoveToParentViewController(self);
                UIView.animateWithDuration(0.3, animations: {()->Void in
                    content.view.alpha = 1;
                    });
            }
            else {
                var old = self.viewControllerDictionary[previouslyShowing]!;
                
                old.willMoveToParentViewController(nil);
                self.addChildViewController(content);
                content.view.frame = self.contentArea.frame;
                self.view.addSubview(content.view);
                //content.didMoveToParentViewController(self);
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {()->Void in
                    content.view.alpha = 1;
                    old.view.alpha = 0;
                    }, completion: {(success: Bool)->Void in
                        old.removeFromParentViewController();
                        content.didMoveToParentViewController(self);
                        old.view.removeFromSuperview();
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
        self.viewControllerDictionary[contentString] = content;
    }
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return SIDE_MENU_ITEMS.count;
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("SideMenuItem", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = SIDE_MENU_NAMES[indexPath.row];
        cell.imageView.image = SIDE_MENU_IMAGES[indexPath.row];
        cell.imageView.frame = CGRectMake(0, 0, 40, 40);
        
        //var backColor = UIColor(red: SIDE_MENU_BACK_RED, green: SIDE_MENU_BACK_GREEN, blue: SIDE_MENU_BACK_BLUE, alpha: 1.0);
        
        var transparentBackgroundView = UIView();
        transparentBackgroundView.backgroundColor = SIDE_MENU_BACK_COLOR;
        transparentBackgroundView.alpha = CGFloat(SIDE_MENU_OPACITIES[indexPath.row]) / DAMPENING_CONSTANT;
        
        //transparentBackgroundView.alpha = 0.1;
        
        //cell.alpha = CGFloat(SIDE_MENU_OPACITIES[indexPath.row]);
        //cell.backgroundColor = backColor;
        cell.backgroundView = transparentBackgroundView;
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        if (SIDE_MENU_ITEMS[indexPath.row] == currentlyShowing) {
            cell.textLabel.textColor = UIColor(white: 1.0, alpha: 0.9);
            cell.imageView.alpha = 0.9;
        }
        else {
            cell.textLabel.textColor = UIColor(white: 1.0, alpha: 0.4);
            cell.imageView.alpha = 0.4;
        }
        
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var boardName = SIDE_MENU_ITEMS[indexPath.row];
        displayContent(boardName);
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
