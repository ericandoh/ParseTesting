//
//  ImagePreviewController.swift
//  ParseStarterProject
//
//  Previews the image before user submission, after image selection
//
//  Created by Eric Oh on 6/25/14.
//
//

import UIKit

class ImagePreviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var labelBar: UITextField;
    
    @IBOutlet var textView: UITextView
    
    @IBOutlet var navigationTitle: UIButton
    
    @IBOutlet var sideTableView: SideTableView
    
    @IBOutlet var mainView: UIView
    
    var movingWindow: Bool = false;
    
    var receivedImages: Array<UIImage> = [];
    
    var prevLabel: String = "";
    var prevDescrip: String = "";
    
    var highlightOrder: Array<ImageIndex> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        labelBar.text = prevLabel;
        textView.text = prevDescrip;
        navigationTitle.setTitle("Edit Post", forState: UIControlState.Normal);
        sideTableView.setEditing(false, animated: false);
    }
    
    //function triggered by pushing check button
    @IBAction func acceptImage(sender: UIButton) {
        //store image and submit (BACKEND)
        /*var choice = exclusiveOptionPanel.selectedSegmentIndex;
        var exclusivity: PostExclusivity = PostExclusivity.EVERYONE;
        switch choice {
            case 1:
                exclusivity = PostExclusivity.FRIENDS_ONLY;
            case 2:
                exclusivity = PostExclusivity.EVERYONE;
            case 3:
                exclusivity = PostExclusivity.MALE_ONLY;
            case 4:
                exclusivity = PostExclusivity.FEMALE_ONLY;
            default:
                exclusivity = PostExclusivity.EVERYONE;
        }*/
        var description = textView.text;
        ServerInteractor.uploadImage(receivedImages, description: description, labels: labelBar!.text);
        
        //reset submission page
        
        
        if (self.navigationController) {
            if (self.navigationController.parentViewController) {
                var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
                overlord.resetWindow(SIDE_MENU_ITEMS[INDEX_OF_UPLOAD]);
                overlord.openHome();
            }
        }
    }
    
    @IBAction func reject(sender: AnyObject) {
        if (self.navigationController) {
            if (self.navigationController.parentViewController) {
                var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
                overlord.resetWindow(SIDE_MENU_ITEMS[INDEX_OF_UPLOAD]);
                overlord.openHome();
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveImage(imageValues: Array<UIImage>, hOrder: Array<ImageIndex>, prevLabel: String, prevDescrip: String) {
        receivedImages = imageValues;
        self.prevLabel = prevLabel;
        self.prevDescrip = prevDescrip;
        self.highlightOrder = hOrder;
    }

    @IBAction func addMoreImages(sender: UIButton) {
        sendBackImages(2);
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
    @IBAction func toggleEdit(sender: UIButton) {
        var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
        var mainOrigin = self.mainView.frame.origin;
        if (sideTableView.editing) {
            navigationTitle.setTitle("Edit Post", forState: UIControlState.Normal);
            sideTableView.setEditing(false, animated: false);
            overlord.setSuppressed(false);
        }
        else {
            navigationTitle.setTitle("Stop Edits", forState: UIControlState.Normal);
            sideTableView.setEditing(true, animated: false);
            overlord.setSuppressed(true);
            var newOrigin = CGPoint(x: mainOrigin.x, y: mainOrigin.y + 20);
            movingWindow = true;
            UIView.animateWithDuration(0.15, animations: {() in
                self.mainView.frame.origin = newOrigin;
                }, completion: {(success: Bool) in
                    UIView.animateWithDuration(0.15, delay: 1.2, options: nil, animations: {() in
                        self.mainView.frame.origin = mainOrigin;
                        }, completion: {(success: Bool) in
                            self.movingWindow = false;
                        });
                });
        }
    }
    
    @IBAction func swiped(sender: UISwipeGestureRecognizer) {
        var point: CGPoint = sender.locationInView(sideTableView);
        var indexPath = sideTableView.indexPathForRowAtPoint(point);
        if (!sideTableView.editing) {
            return;
        }
        if (point.x > UPLOAD_TABLE_DELETE_LIMIT) {
            return;
        }
        if (movingWindow){
            //window is in animation state
            return;
        }
        if (highlightOrder.count == 1) {
            //cant delete last image in post
            return;
        }
        if (indexPath) {
            highlightOrder.removeAtIndex(indexPath.row);
            receivedImages.removeAtIndex(indexPath.row);
            sideTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right);
            /*var cell = sideTableView.cellForRowAtIndexPath(indexPath);
            if (cell) {
                var oldP = cell.frame.origin;
                var newP = CGPoint(x: oldP.x - 30, y: oldP.y);
                UIView.animateWithDuration(0.3, animations: {()->Void in
                    cell.frame.origin = oldP;
                    cell.alpha = 0;
                    }, completion: {(finish: Bool) in
                        //delete cell
                    })
            }*/
        }
    }
    
    func sendBackImages(seeBack: Int) {
        self.receivedImages = [];
        var currentIndex = self.navigationController.viewControllers.count;
        if (currentIndex >= seeBack) {
            var prevController: UIViewController = self.navigationController.viewControllers[currentIndex - seeBack] as UIViewController;
            if (prevController is ImagePickingViewController) {
                (prevController as ImagePickingViewController).receivePreviousImages(labelBar.text, prevDescrip: textView.text, prevOrder: highlightOrder);
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        if (self.navigationController.viewControllers.bridgeToObjectiveC().indexOfObject(self) == NSNotFound) {
            sendBackImages(1);
        }
        super.viewWillDisappear(animated);
    }

    
    
/*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        //-------THIS METHOD DOES NOT RUN--------------
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue!.destinationViewController is ImagePickingViewController) {
            (segue!.destinationViewController as ImagePickingViewController).receivePreviousImages(labelBar.text, prevDescrip: textView.text);
        }
    }
    */
    
    //------table methods-----------
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int  {
        return 1;
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return receivedImages.count;
    }
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: SideTableViewCell = tableView!.dequeueReusableCellWithIdentifier("SideCell", forIndexPath: indexPath) as SideTableViewCell;
        
        //cell.textLabel.text = "Yolo";
        
        cell.setImage(receivedImages[indexPath.row]);
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    /*func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)  {
        var row = indexPath.row;

    }*/
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return !movingWindow;
    }
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!)  {
        var oldR = sourceIndexPath.row;
        var newR = destinationIndexPath.row;
        var oldIndex = highlightOrder.removeAtIndex(oldR);
        var oldImg = receivedImages.removeAtIndex(oldR);
        highlightOrder.insert(oldIndex, atIndex: newR);
        receivedImages.insert(oldImg, atIndex: newR);
    }
    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None;
    }
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        /*if (editingStyle == UITableViewCellEditingStyle.Delete){
            highlightOrder.removeAtIndex(indexPath.row);
            receivedImages.removeAtIndex(indexPath.row);
        }*/
    }

}
