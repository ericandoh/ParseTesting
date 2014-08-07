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

class ShopButton: UIView {
    var shopIndex: Int = -1;
}
class ShopTextButton: UIButton {
    var shopIndex: Int = -1;
}

class ImagePreviewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet var labelBar: UITextField!;
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var navigationTitle: UIButton!
    
    @IBOutlet var sideTableView: SideTableView!
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var shopTheLookView: UIView!
    
    @IBOutlet var shopTheLookConstraint: NSLayoutConstraint!
    
    @IBOutlet var mainWindowConstraint: NSLayoutConstraint!
    
    @IBOutlet var slideDownConstraint: NSLayoutConstraint!
    
    @IBOutlet var backDirectionImage: UIImageView!
    
    @IBOutlet weak var backImageView: UIImageView!
    
    
    var movingWindow: Bool = false;
    
    var receivedImages: Array<UIImage> = [];
    
    var prevLabel: String = "";
    var prevDescrip: String = "";
    
    var highlightOrder: Array<ImageIndex> = [];
    
    var shopTheLook: Array<ShopLook> = [];
    
    var shopButtons: Array<ShopButton> = [];
    
    var placeholding: Bool = false;
    
    var isEditingExisting = false;
    
    var existingPost: ImagePostStructure?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = UIColor.whiteColor().CGColor;
        //textView.layer.cornerRadius = 8;
        textView.delegate = self;
        
        labelBar.borderStyle = UITextBorderStyle.None;
        labelBar.layer.borderWidth = 1;
        labelBar.layer.borderColor = UIColor.whiteColor().CGColor;
        
        labelBar.text = prevLabel;
        if (prevDescrip == "") {
            setPlaceholderText();
        }
        else {
            textView.text = prevDescrip;
        }
        
        scrollView.contentSize = CGSize(width: 320, height: SCROLLFIELD_DEFAULT_HEIGHT);   //595;
        
        if (shopTheLook.count > 0) {
            scrollView.contentSize = CGSize(width: 320, height: SCROLLFIELD_DEFAULT_HEIGHT + CGFloat(shopTheLook.count) * BOX_INCR_Y);
            
            for (index, look) in enumerate(shopTheLook) {
                var oldY = BOX_START_Y + CGFloat(index) * BOX_INCR_Y;
                var newButton = ShopButton(frame: CGRectMake(BOX_LEFT_MARGIN, oldY, BOX_WIDTH, LABEL_BOX_HEIGHT));
                featurizeShopButton(index, shopButton: newButton);
            }
        }
        
        navigationTitle.setTitle("Edit Post", forState: UIControlState.Normal);
        sideTableView.setEditing(false, animated: false);
        
        if (receivedImages.count > 0) {
            backImageView.image = receivedImages[0];
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        /*if (receivedImages.count > 0) {
            backImageView.image = receivedImages[0];
        }*/
    }
    
    func setPlaceholderText() {
        placeholding = true;
        textView.textColor = PLACEHOLDER_COLOR;
        textView.text = PREVIEW_DESCRIP_PLACEHOLDER_TEXT
    }
    
    //called when a new shopbutton is made, and featurizes the button
    func featurizeShopButton(index: Int, shopButton: ShopButton) {
        
        shopButton.backgroundColor = UIColor.clearColor();
        
        shopButton.shopIndex = index;
        var but1 = ShopTextButton(frame: CGRectMake(0, 0, BOX_WIDTH_ONE, LABEL_BOX_HEIGHT));
        var but2 = ShopTextButton(frame: CGRectMake(BOX_WIDTH_ONE, 0, BOX_CLOSE_WIDTH, LABEL_BOX_HEIGHT));
        but1.backgroundColor = UIColor.clearColor();
        but2.backgroundColor = UIColor.clearColor();
        but1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        but2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        but1.shopIndex = index;
        but2.shopIndex = index;
        
        but1.addTarget(self, action: "editShopTheLook:", forControlEvents: UIControlEvents.TouchDown);
        but2.addTarget(self, action: "removeShopTheLook:", forControlEvents: UIControlEvents.TouchDown);
        but1.setTitle(shopTheLook[index].title, forState: UIControlState.Normal);
        but1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        but1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        but2.setImage(CLOSE_SHOP_EDIT_ICON, forState: UIControlState.Normal);
        shopButton.backgroundColor = UIColor.blackColor();
        
        shopButton.addSubview(but1);
        shopButton.addSubview(but2);
        
        shopButtons.append(shopButton);
        mainView.addSubview(shopButton);
        
        shopTheLookConstraint.constant = shopTheLookConstraint.constant + BOX_INCR_Y;
        mainWindowConstraint.constant = mainWindowConstraint.constant + BOX_INCR_Y;
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
        var description = "";
        if (!placeholding) {
            description = textView.text;
        }
        if (isEditingExisting) {
            ServerInteractor.updatePost(existingPost!, imgs: receivedImages, description: description, labels: labelBar!.text, looks: shopTheLook);
            self.navigationController.popViewControllerAnimated(true);
        }
        else {
            ServerInteractor.uploadImage(receivedImages, description: description, labels: labelBar!.text, looks: shopTheLook);
            
            //reset submission page
            if (self.navigationController) {
                if (self.navigationController.parentViewController) {
                    var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
                    overlord.resetWindow(SIDE_MENU_ITEMS[INDEX_OF_UPLOAD]);
                    overlord.openHome();
                }
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
    
    func receiveImage(imageValues: Array<UIImage>, hOrder: Array<ImageIndex>, prevLabel: String, prevDescrip: String, prevShop: Array<ShopLook>) {
        self.isEditingExisting = false;
        receivedImages = imageValues;
        self.prevLabel = prevLabel;
        self.prevDescrip = prevDescrip;
        self.highlightOrder = hOrder;
        self.shopTheLook = prevShop;
    }
    
    func receiveImage(imageValues: Array<UIImage>, post: ImagePostStructure) {
        
        var prevLabel = post.getLabels();
        var prevDescrip = post.getDescription();
        var prevShop = post.getShopLooks();
        
        self.isEditingExisting = true;
        receivedImages = imageValues;
        self.prevLabel = prevLabel;
        self.prevDescrip = prevDescrip;
        var hOrder = Array<ImageIndex>();
        for i in 0..<imageValues.count {
            hOrder.append(ImageIndex(groupNum: -1, index: i, asset: nil));
        }
        self.highlightOrder = hOrder;
        self.shopTheLook = prevShop;
        self.existingPost = post;
    }

    @IBAction func addMoreImages(sender: UIButton) {
        //NSLog("Deprecated!")
        //sendBackImages(2);
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
    @IBAction func toggleEdit(sender: UIButton) {
        var overlord = self.navigationController.parentViewController as SideMenuManagingViewController;
        var mainOrigin = self.mainView.frame.origin;
        if (sideTableView.editing) {
            navigationTitle.setTitle("Edit Post", forState: UIControlState.Normal);
            sideTableView.setEditing(false, animated: false);
            overlord.setSuppressed(false);
            scrollView.scrollEnabled = true;
            self.slideDownConstraint.constant = self.slideDownConstraint.constant - 30;
            UIView.animateWithDuration(0.2, animations: {() in
                self.backDirectionImage.alpha = 0;
                }, completion: {(success: Bool) in
                    self.backDirectionImage.hidden = true;
                });
            /*UIView.animateWithDuration(0.15, animations: {() in
                self.slideDownConstraint.constant = self.slideDownConstraint.constant - 40;
                });*/
        }
        else {
            navigationTitle.setTitle("Stop Edits", forState: UIControlState.Normal);
            sideTableView.setEditing(true, animated: false);
            overlord.setSuppressed(true);
            var newOrigin = CGPoint(x: mainOrigin.x, y: mainOrigin.y + 20);
            scrollView.scrollEnabled = false;
            scrollView.setContentOffset(CGPointZero, animated: true);
            self.slideDownConstraint.constant = self.slideDownConstraint.constant + 30;
            backDirectionImage.alpha = 0;
            backDirectionImage.hidden = false;
            UIView.animateWithDuration(0.2, animations: {() in
                self.backDirectionImage.alpha = 1;
                });
            /*UIView.animateWithDuration(0.15, animations: {() in
                self.slideDownConstraint.constant = self.slideDownConstraint.constant + 40;
            });*/
            /*UIView.animateWithDuration(0.15, animations: {() in
                self.mainView.frame.origin = newOrigin;
                }, completion: {(success: Bool) in
                    UIView.animateWithDuration(0.15, delay: 1.2, options: nil, animations: {() in
                        self.mainView.frame.origin = mainOrigin;
                        }, completion: {(success: Bool) in
                            self.movingWindow = false;
                        });
                });*/
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
    
    
    @IBAction func addShopTheLook(sender: UIButton) {
        let alert: UIAlertController = UIAlertController(title: "Shop the Look!", message: "Describe it!", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Title/Short Description";
        });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Link where I can get it!";
            });
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var title = (alert.textFields[0] as UITextField).text;
            var urlLink = (alert.textFields[1] as UITextField).text;
            self.addManualShopTheLook(ShopLook(title: title, urlLink: urlLink));
            }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func editShopTheLook(sender: UIButton!) {
        var thisButton = sender as ShopTextButton;
        let index = thisButton.shopIndex;
        let alert: UIAlertController = UIAlertController(title: "Shop the Look!", message: "Describe it!", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Title/Short Description";
            });
        alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
            field.placeholder = "Link where I can get it!";
            });
        (alert.textFields[0] as UITextField).text = shopTheLook[index].title;
        (alert.textFields[1] as UITextField).text = shopTheLook[index].urlLink;
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            var title = (alert.textFields[0] as UITextField).text;
            var urlLink = (alert.textFields[1] as UITextField).text;
            self.shopTheLook[index] = ShopLook(title: title, urlLink: urlLink);
            thisButton.setTitle(title, forState: UIControlState.Normal);
            }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func removeShopTheLook(sender: UIButton!) {
        let thisButton = sender as ShopTextButton;
        let index = thisButton.shopIndex;
        let alert: UIAlertController = UIAlertController(title: "Delete?", message: "Delete this ShopTheLook?", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "Delete!", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            
            for i in (index+1)...(self.shopButtons.count - 1) {
                var oldY = BOX_START_Y + CGFloat(i - 1) * BOX_INCR_Y;
                self.shopButtons[i].frame = CGRectMake(BOX_LEFT_MARGIN, oldY, BOX_WIDTH, LABEL_BOX_HEIGHT);
                self.shopButtons[i].shopIndex = i-1;
                (self.shopButtons[i].subviews[0] as ShopTextButton).shopIndex = i - 1;
                (self.shopButtons[i].subviews[1] as ShopTextButton).shopIndex = i - 1;
            }
            
            var button = self.shopButtons.removeAtIndex(index)
            self.shopTheLook.removeAtIndex(index);
            button.removeFromSuperview();
            
            self.shopTheLookConstraint.constant = self.shopTheLookConstraint.constant - BOX_INCR_Y;
            self.mainWindowConstraint.constant = self.mainWindowConstraint.constant - BOX_INCR_Y;
            
            self.scrollView.contentSize = CGSize(width: 320, height: SCROLLFIELD_DEFAULT_HEIGHT + CGFloat(self.shopTheLook.count) * BOX_INCR_Y);
            }));
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func whatIsShopTheLook(sender: UIButton) {
        let alert: UIAlertController = UIAlertController(title: "What is Shop the Look?", message: "Simply add a title to the items in your collection, and optionally a url where you can get it!\n\nExample Title: Women Retro Fashion Square Glasses\nExample URL: https://shoplately.com/product/362632/women_retro_fashion_square_sunglasses_black_lens_black_frame", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            }));
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func addManualShopTheLook(look: ShopLook) {
        //function for pushing down stack
        shopTheLook.append(look);
        scrollView.contentSize = CGSize(width: 320, height: SCROLLFIELD_DEFAULT_HEIGHT + CGFloat(shopTheLook.count) * BOX_INCR_Y);
        
        var oldY = BOX_START_Y + CGFloat(shopTheLook.count - 1) * BOX_INCR_Y;
        var newY = BOX_START_Y + CGFloat(shopTheLook.count) * BOX_INCR_Y;
        var newButton = ShopButton(frame: CGRectMake(BOX_LEFT_MARGIN, oldY, BOX_WIDTH, LABEL_BOX_HEIGHT));
        
        featurizeShopButton(shopTheLook.count - 1, shopButton: newButton);
    }
    func sendBackImages(seeBack: Int) {
        self.receivedImages = [];
        var currentIndex = self.navigationController.viewControllers.count;
        if (currentIndex >= seeBack) {
            var prevController: UIViewController = self.navigationController.viewControllers[currentIndex - seeBack] as UIViewController;
            if (prevController is ImagePickingViewController) {
                var sendBackText = "";
                if (!placeholding) {
                    sendBackText = textView.text;
                }
                
                (prevController as ImagePickingViewController).receivePreviousImages(labelBar.text, prevDescrip: sendBackText, prevOrder: highlightOrder, prevShop: shopTheLook);
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        if ((self.navigationController.viewControllers as NSArray).indexOfObject(self) == NSNotFound) {
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
    
    //-------textview delegate methods------
    func textViewShouldBeginEditing(textView: UITextView!) -> Bool {
        if (placeholding) {
            textView.text = "";
            textView.textColor = PREVIEW_TEXT_VIEW_COLOR;
            placeholding = false;
        }
        return true;
    }
    func textViewDidChange(textView: UITextView!) {
        if (textView.text == "") {
            setPlaceholderText();
            textView.resignFirstResponder();
        }
    }

}
