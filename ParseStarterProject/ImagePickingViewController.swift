//
//  InteractiveGalleryPickerViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/24/14.
//
//


import UIKit
import AssetsLibrary

let SAVED_PHOTOS_NAME = "Saved Photos"
let CAMERA_ROLL_NAME = "Camera Roll"

struct ImageIndex: Equatable {
    var groupNum: Int;
    var index: Int;
    var asset: ALAsset?;
}
func == (lhs: ImageIndex, rhs: ImageIndex)->Bool {
    return lhs.groupNum == rhs.groupNum && lhs.index == rhs.index;
}

struct AssetItem {
    var asset: ALAsset?;
    var highlighted: Int;
}

class ImagePickingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var optionsView: UIView!
    @IBOutlet var myCollectionView: UICollectionView!
    //@IBOutlet var myTableView: UITableView!
    
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet var navigationTitle: UIButton!
    @IBOutlet weak var backImageView: BlurringDarkView!
    @IBOutlet weak var backButton: UIButton!
    
    var assetLibrary: ALAssetsLibrary?;
    
    var assetGroups: Array<ALAssetsGroup> = [];
    
    var currentAssets: Array<AssetItem> = [];
    
    var groupSelected: Int = -1;
    var showingOptions: Bool = false;
    
    //list of indexes in order of selection
    var highlightOrder: Array<ImageIndex> = [];
    
    var usingCamera: Bool = false;
    
    var savedPhotoIndex: Int = 0;
    
    var retList: Array<UIImage> = [];
    
    var prevLabel: String = "";
    var prevDescrip: String = "";
    var shopLook: Array<ShopLook> = [];
    
    var imageRenderDirection: Int = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                backButton.setBackgroundImage(BACK_ICON, forState: UIControlState.Normal);
            }
        }

        if (self.navigationController!.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController!.interactivePopGestureRecognizer.enabled = false;
        }
        
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationTitle.setTitle("", forState: UIControlState.Normal);
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
        
        
        var toolbar = UIToolbar(frame: optionsView.frame);
        toolbar.barStyle = UIBarStyle.Black;
        toolbar.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
        self.optionsView.insertSubview(toolbar, atIndex: 0);
        optionsView.hidden = true;  //this should be set to this by storyboard by default
        
        //NSLog("Loading View");
        // Do any additional setup after loading the view.
        //assetLibrary = ALAssetsLibrary();
        //ImagePickingViewController.getDefaultAssetLibrary();
        //dispatch_async(dispatch_get_main_queue(), {
            //autoreleasepool {
                var failure: ALAssetsLibraryAccessFailureBlock = {
                    (error: NSError!)->Void in
                    NSLog(error.description)
                    //assetLibrary!
                    //NSLog("Add alert view telling I couldn't open my images");
                };
                //var groupEnumeration: ALAssetsGroupEnumerationResultsBlock = {
                    
                //};
                var libraryGroupEnumeration: ALAssetsLibraryGroupsEnumerationResultsBlock = {
                    (group, stop) in
                    //var insideLibrary = self.assetLibrary;
                    if (group != nil) {
                        group.setAssetsFilter(ALAssetsFilter.allPhotos());
                        /*
                        group.posterImage -> small image for icon
                        */
                        self.assetGroups.append(group);
                        //if (self.assetGroups.count == 1) {
                        if (self.getGalleryTimeForIndex(self.assetGroups.count - 1) == SAVED_PHOTOS_NAME || self.getGalleryTimeForIndex(self.assetGroups.count - 1) == CAMERA_ROLL_NAME) {
                            //first asset I've loaded
                            //NSLog("First asset group, adding + loading")
                            var name: String = self.getGalleryFullName(self.assetGroups.count - 1) + " ▾";
                            self.navigationTitle.setTitle(name, forState: UIControlState.Normal);
                            self.savedPhotoIndex = self.assetGroups.count - 1;
                            self.groupSelected = self.savedPhotoIndex;
                            self.loadImagesForCurrent();
                        }
                    }
                    else {
                    }
                };
                self.assetLibrary = ALAssetsLibrary();
                //ALAssetsGroupType(ALAssetsGroupAll)
                self.assetLibrary!.enumerateGroupsWithTypes(0xFFFFFFFF, usingBlock: libraryGroupEnumeration, failureBlock: failure)
           // }
        //});
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if (backImageView.image != nil) {
            backImageView.setImageAndBlur(ServerInteractor.cropImageSoNavigationWorksCorrectly(backImageView.image!, frame: backImageView.frame));
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getGalleryTimeForIndex(groupIndex: Int)->String {
        return assetGroups[groupIndex].valueForProperty(ALAssetsGroupPropertyName as String) as String
        
    }
    func getGalleryFullName(groupIndex: Int)->String {
        var name: String = getGalleryTimeForIndex(groupIndex);
        name = name + " (" + String(assetGroups[groupIndex].numberOfAssets()) + ")";
        return name;
    }
    
    func loadImagesForCurrent() {
        //fills up collection view
        NSLog("\(groupSelected) and \(assetGroups.count)")
        var numAssets = assetGroups[groupSelected].numberOfAssets();
        
        currentAssets = Array(count: numAssets, repeatedValue: AssetItem(asset: nil, highlighted: -1));
        //currentAssets = [];
        self.myCollectionView.reloadData();
        imageRenderDirection = 0;
        var firstDate = NSDate();
        /*for (loc, check: ImageIndex) in enumerate(highlightOrder) {
            if (check.groupNum == groupSelected) {
                currentAssets[check.index].highlighted = loc;
            }
        }*/
        for (loc, check: ImageIndex) in enumerate(self.highlightOrder) {
            if (check.groupNum == self.groupSelected) {
                self.currentAssets[check.index].highlighted = loc;
                //self.highlightOrder[loc].asset = self.currentAssets[check.index].asset
            }
        }
        var currentGroup = assetGroups[groupSelected];
        var totalEnumerated: Int = 0;
        var reloadAtIndexPaths: Array<NSIndexPath> = [];
        currentGroup.enumerateAssetsUsingBlock({
            (result, index, stop) in
            //NSLog("Loading asset \(index)")
            if (result == nil) {
                return;
            }
            if (index == 0) {
                var assetImg = UIImage(CGImage: result.defaultRepresentation().fullResolutionImage().takeUnretainedValue());
                //self.backImageView.image = assetImg;
                self.backImageView.setImageAndBlur(assetImg!);
                firstDate = result.valueForProperty(ALAssetPropertyDate) as NSDate;
            }
            else if (index == 1) {
                var secondDate = result.valueForProperty(ALAssetPropertyDate) as NSDate;
                if (firstDate.compare(secondDate) == NSComparisonResult.OrderedAscending) {
                    self.imageRenderDirection = -1;
                    //self.currentAssets[numAssets - 1].asset = self.currentAssets[0].asset
                }
                else if (firstDate.compare(secondDate) == NSComparisonResult.OrderedDescending) {
                    //direction is right
                    self.imageRenderDirection = 1;
                }
            }
            if(index < self.currentAssets.count) {
                self.currentAssets[index].asset = result;
                reloadAtIndexPaths.append(NSIndexPath(forRow: index+1, inSection: 0));
                //self.myCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index + 1, inSection: 0)]);
            }
            else {
                var currentCount = self.currentAssets.count;
                self.currentAssets += Array(count: index-currentCount + 1, repeatedValue: AssetItem(asset: nil, highlighted: -1));
                self.currentAssets[index].asset = result;
                reloadAtIndexPaths.append(NSIndexPath(forRow: index+1, inSection: 0));
                //var indexPaths: Array<NSIndexPath> = [];
                //for i in currentCount..<(index+1) {
                    //indexPaths.append(NSIndexPath(forRow: i + 1, inSection: 0));
                //}
                //self.myCollectionView.insertItemsAtIndexPaths(indexPaths);
            }
            //self.currentAssets[index].asset = result;
            //self.myCollectionView.reloadData();
            totalEnumerated++;
            if (totalEnumerated == numAssets) {
                self.myCollectionView.reloadData();
                for (loc, check: ImageIndex) in enumerate(self.highlightOrder) {
                    if (check.groupNum == self.groupSelected) {
                        //self.currentAssets[check.index].highlighted = loc;
                        self.highlightOrder[loc].asset = self.currentAssets[check.index].asset
                    }
                }
            }
            else if (reloadAtIndexPaths.count > 10) {
                //reload table every 10
                self.myCollectionView.reloadItemsAtIndexPaths(reloadAtIndexPaths);
                reloadAtIndexPaths = [];
            }
            });
    }
    
    
    @IBAction func outsidePickerClicked(sender: UIButton) {
        optionsView.hidden = true;
    }
    
    @IBAction func optionsClickedOK(sender: UIButton) {
        var selected = myPickerView.selectedRowInComponent(0);
        switchViewsFromOptionsTo(selected);
    }
    
    //--------uipicker methods------------
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (showingOptions) {
            return assetGroups.count + 1;
        }
        return 0;
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var returnLine = "Uncheck All Photos";
        if (row < assetGroups.count) {
            returnLine = self.getGalleryFullName(row);
        }
        var attrString = NSAttributedString(string: returnLine, attributes: [NSForegroundColorAttributeName: (TITLE_TEXT_COLOR as AnyObject), NSFontAttributeName: (TABLE_CELL_FONT as AnyObject)]);
        return attrString;
    }
    /*func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        //do nothing
    }*/
    func switchViewsFromOptionsTo(row: Int) {
        self.showingOptions = false;
        if (row >= assetGroups.count) {
            for (index, item) in enumerate(currentAssets) {
                currentAssets[index] = AssetItem(asset: currentAssets[index].asset, highlighted: -1);
            }
            highlightOrder = [];
            optionsView.hidden = true;
            myCollectionView.reloadData();
            return;
        }
        groupSelected = row;
        loadImagesForCurrent();
        optionsView.hidden = true;
        var name = getGalleryFullName(row) + " ▾";
        self.navigationTitle.setTitle(name, forState: UIControlState.Normal);
    }
    //--------collectionview methods------------
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int  {
        return 1;
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (assetGroups.count == 0) {
            return 1;
        }
        //NSLog("We are returning that we have \(self.currentAssets.count) cells")
        return self.currentAssets.count + 1;
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        var cell: PreviewCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as PreviewCollectionViewCell;
        var row = indexPath.row;
        
        if (row == 0) {
            //render a camera icon
            //cell.backgroundColor = UIColor.redColor();
            cell.makeVisible();
            cell.label.text = "";
            cell.image.image = CAMERA_ICON;
            return cell;
        }
        row--;
        
        if(imageRenderDirection == -1) {
            row = self.currentAssets.count - 1 - row;
        }
        
        if (self.currentAssets[row].asset == nil) {
            cell.label.text = "";
            cell.image.image = UIImage();
            return cell;
        }
        cell.image.image = UIImage(CGImage: self.currentAssets[row].asset!.thumbnail().takeUnretainedValue());
        if (self.currentAssets[row].highlighted != -1) {
            //cell.backgroundColor = UIColor.yellowColor();
            cell.darkenImage();
            cell.label.text = String(find(highlightOrder, ImageIndex(groupNum: groupSelected, index: row, asset: nil))! + 1);   //for those damn nonprogrammer people
        }
        else {
            //cell.backgroundColor = UIColor.redColor();
            cell.makeVisible();
            cell.label.text = "";
        }
        return cell;
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!)  {
        var row = indexPath.row;
        
        if (row == 0) {
            //open camera
            cameraAction();
            return;
        }
        row--;
        if(imageRenderDirection == -1) {
            row = self.currentAssets.count - 1 - row;
        }
        if (self.currentAssets[row].highlighted == -1) {
            //needs to be highlighted
            var assetItem: AssetItem =  self.currentAssets[row];
            assetItem.highlighted = highlightOrder.count;
            self.currentAssets[row] = assetItem;
            highlightOrder.append(ImageIndex(groupNum: groupSelected, index: row, asset: self.currentAssets[row].asset));
        }
        else {
            //unhighlight
            var loc = find(highlightOrder, ImageIndex(groupNum: groupSelected, index: row, asset: nil));
            highlightOrder.removeAtIndex(loc!);
            var assetItem: AssetItem =  self.currentAssets[row];
            assetItem.highlighted = -1;
            self.currentAssets[row] = assetItem;
        }
        collectionView.reloadData();
        //collectionView.reloadItemsAtIndexPaths([indexPath]);
    }
    
    //camera methods
    func cameraAction() {
        if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            NSLog("Camera not available");
            self.imageSavingError("Camera Not Available!");
        }
        else {
            self.usingCamera = true;
            ImagePickingViewController.startCameraFromViewController(self, usingDelegate: self)
            NSLog("Done showing");
        }
    }
    
    class func startCameraFromViewController(controller: UIViewController, usingDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)-> Bool {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            
            var imagePicker :UIImagePickerController = UIImagePickerController();
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.mediaTypes = NSArray(object: kUTTypeImage);
            imagePicker.allowsEditing = false;
            imagePicker.delegate = delegate;

            controller.presentViewController(imagePicker, animated:true, completion:nil);
            
            return true;
        }
        else {
            return false;
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        NSLog("Done");
        var mediaType: NSString = info[UIImagePickerControllerMediaType] as NSString;
        self.dismissViewControllerAnimated(false, completion: {
            ()->Void in
            if (mediaType == kUTTypeImage) {//kUTTypeImage) {
                var image: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage;
                //self.backImageView.image = image;
                self.backImageView.setImageAndBlur(image);
                //add code here to do something with image I just picked
                if (self.usingCamera) {
                    /*UIImageWriteToSavedPhotosAlbum(image,
                    self,
                    "image:finishedSavingWithError:contextInfo:",
                    nil);*/
                    //self.assetLibrary!.saveImage(image, toAlbum: "Touch", withCompletionBlock: {(error: NSError!) in });
                    self.assetLibrary!.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Right, completionBlock:
                        {(assertURL: NSURL!, error: NSError!) in
                            if ((error) != nil) {
                                self.imageSavingError("Failed to save image");
                            }
                            else {
                                //do stuff with image
                                self.assetLibrary!.assetForURL(assertURL, resultBlock: {(asset: ALAsset!) in
                                    //we have our asset
                                    self.groupSelected = self.savedPhotoIndex;
                                    //just added an image, so should shift all currently selected images by one index
                                    for (index, imageIndex) in enumerate(self.highlightOrder) {
                                        if (imageIndex.groupNum == self.savedPhotoIndex && imageIndex.index != -1) {
                                            self.highlightOrder[index] = ImageIndex(groupNum: self.savedPhotoIndex, index: imageIndex.index + 1, asset: asset);
                                        }
                                    }
                                    NSLog("Should reload here, does it?");
                                    self.loadImagesForCurrent();
                                    self.myCollectionView.reloadData();
                                    var name = self.getGalleryFullName(self.savedPhotoIndex) + " ▾";
                                    self.navigationTitle.setTitle(name, forState: UIControlState.Normal);
                                    
                                    
                                    
                                    }, failureBlock: {(error: NSError!) in
                                        //we have our error
                                        self.imageSavingError("Failed to load asset after saving");
                                    });
                            }
                        })
                    
                }
                //start segue
                //self.performSegueWithIdentifier("ImagePreview", sender:self);
                
                
            }
            else if (mediaType == kUTTypeMovie) {
                // Code here to support video if enabled
            }});
    }
    func imageSavingError(errorString: String) {
        CompatibleAlertViews.makeNotice("Image failure", message: errorString, presenter: self)
        /*let alert: UIAlertController = UIAlertController(title: "Image failure", message: errorString, preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            //canceled
            }));
        self.presentViewController(alert, animated: true, completion: nil)*/
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil);
        /*if (self.navigationController) {
        if (self.navigationController!.parentViewController) {
        var overlord = self.navigationController!.parentViewController as SideMenuManagingViewController;
        overlord.openHome();
        }
        }*/
    }
    
    
    
    @IBAction func clickedNavTitle(sender: AnyObject) {
        optionsView.hidden = false;
        self.showingOptions = true;
        myPickerView.reloadAllComponents();
    }
    
    
    @IBAction func previousButton(sender: UIButton) {
        if ((self.navigationController) != nil) {
            (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu()
        }
        else {
            NSLog("If this is logging, somehow this imagepicker lost its navigation controller. Uh oh!")
        }
    }
    
    @IBAction func nextButton(sender: UIButton) {
        //var retImgList: Array<UIImage> = [];
        if (highlightOrder.count == 0) {
            //no images selected
            return;
        }
        
        retList = [];
        var groupSelected: Int;
        var row: Int;
        var asset: ALAsset;
        for index:ImageIndex in highlightOrder {
            groupSelected = index.groupNum;
            row = index.index;
            asset = index.asset!; //self.currentAssets[row];
            retList.append(UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())!);
        }
        //call some function to segue and get ready to pass this list on
        self.performSegueWithIdentifier("ImagePreview", sender: self);
    }
    
    func receivePreviousImages(prevLabel: String, prevDescrip: String, prevOrder: Array<ImageIndex>, prevShop: Array<ShopLook>) {
        self.prevLabel = prevLabel;
        self.prevDescrip = prevDescrip;
        self.shopLook = prevShop;
        highlightOrder = prevOrder;
        for (index, item) in enumerate(currentAssets) {
            currentAssets[index] = AssetItem(asset: currentAssets[index].asset, highlighted: -1);
        }
        for (index, item) in enumerate(highlightOrder) {
            if (item.groupNum == groupSelected) {
                currentAssets[item.index] = AssetItem(asset: currentAssets[item.index].asset, highlighted: index);
            }
        }
        loadImagesForCurrent();
        //myTableView.reloadData();
    }
    
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.destinationViewController is ImagePreviewController) {
            var nextController = segue.destinationViewController as ImagePreviewController;
            //currImgs.append(pickedImage!);
            nextController.receiveImage(retList, hOrder: highlightOrder, prevLabel: prevLabel, prevDescrip: prevDescrip, prevShop: shopLook);
        }
        else {
            NSLog("Destination View Controller mismatch???");
            NSLog("Id: %@", segue.identifier!);
        }
    }
    
}

