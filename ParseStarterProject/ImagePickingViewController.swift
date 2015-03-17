//
//  InteractiveGalleryPickerViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/24/14.
//
//

import Foundation
import UIKit
import AssetsLibrary

let SAVED_PHOTOS_NAME = "Saved Photos"
let CAMERA_ROLL_NAME = "Camera Roll"

struct ImageIndex: Equatable {
    var groupNum: Int;
    var index: Int;
    //var asset: ALAsset?;
    var assetImg: UIImage?;
}
func == (lhs: ImageIndex, rhs: ImageIndex)->Bool {
    return lhs.groupNum == rhs.groupNum && lhs.index == rhs.index;
}

struct AssetItem {
    //var asset: ALAsset?;
    var highlighted: Int;
    var assetImg: UIImage?;
    var thumbnail: UIImage?;
}

@objc class ImagePickingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, CTAssetsPickerControllerDelegate {
    
    @IBOutlet var optionsView: UIView!
    @IBOutlet var myCollectionView: UICollectionView!
    
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet var navigationTitle: UIButton!
    @IBOutlet weak var backImageView: BlurringDarkView!
    @IBOutlet weak var backButton: UIButton!
    var popover : UIPopoverController!
    
    var assetLibrary: ALAssetsLibrary?;
    
    var assetGroups: Array<ALAssetsGroup> = [];
    
    var assetLoadedCount: Int = 0;
    
    var totalAssetsHere: Int = 0;
    
    var loadingAssets: Bool = false;
    
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
    
    var photos : Array<ALAsset> = []
    
    //var imageRenderDirection: Int = 0;
    let photosPerPage = 10//15//20
    
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

        myCollectionView.pagingEnabled = true
        //AssetItem(asset: nil, highlighted: -1)
        currentAssets = Array(count: GALLERY_LOAD_LIMIT, repeatedValue: AssetItem(highlighted: -1, assetImg: nil, thumbnail: nil));
        
        // load saved photos when click upload tab in side menu
        self.loadPhotos()
        
        var failure: ALAssetsLibraryAccessFailureBlock = {
            (error: NSError!)->Void in
            NSLog(error.description)
        };
        var libraryGroupEnumeration: ALAssetsLibraryGroupsEnumerationResultsBlock = {
            (group, stop) in
            if (group != nil) {
                group.setAssetsFilter(ALAssetsFilter.allPhotos()); // import all photos
                /*
                group.posterImage -> small image for icon
                */
                self.assetGroups.append(group); NSLog("Group name: \(self.getGalleryTimeForIndex(self.assetGroups.count - 1))")
                if (self.getGalleryTimeForIndex(self.assetGroups.count - 1) == SAVED_PHOTOS_NAME || self.getGalleryTimeForIndex(self.assetGroups.count - 1) == CAMERA_ROLL_NAME) {
                    //first asset I've loaded
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
//        self.assetLibrary!.enumerateGroupsWithTypes(0xFFFFFFFF, usingBlock: libraryGroupEnumeration, failureBlock: failure)
        
        // pick multiple photos after tapping nav title, uncomment the above lines if restore to pick from albums in circular buffer way
        self.navigationTitle.setTitle("Pick Photos", forState: UIControlState.Normal)
        self.groupSelected = 0
        for arrayAllIndex in 0..<photosPerPage {
            self.currentAssets[arrayAllIndex].highlighted = -1;
            if (self.currentAssets[arrayAllIndex].thumbnail != nil) {
                NSLog("-----passed successfully with id: \(arrayAllIndex)------")
            }
        }
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
    
    override func viewWillAppear(animated: Bool) {
        self.rehighlightCells2()
    }
    
    func getGalleryTimeForIndex(groupIndex: Int)->String {
        return assetGroups[groupIndex].valueForProperty(ALAssetsGroupPropertyName as String) as String
        
    }
    func getGalleryFullName(groupIndex: Int)->String {
        var name: String = getGalleryTimeForIndex(groupIndex);
        name = name + " (" + String(assetGroups[groupIndex].numberOfAssets()) + ")";
        return name;
    }
    
    func assetArrayIndexToRealIndex(index: Int) -> Int {
        let remainder = assetLoadedCount % GALLERY_LOAD_LIMIT;
        let prev = assetLoadedCount - remainder;
        if (index < remainder) {
            return index + prev;
        }
        else if (index < GALLERY_LOAD_LIMIT) {
            return index + prev - GALLERY_LOAD_LIMIT;
        }
        else {
            //invalid
            return -1;
        }
    }
    func realIndexToAssetArrayIndex(index: Int) -> Int {
        if (index >= assetLoadedCount) {
            return -1;
        }
        if (index < assetLoadedCount - GALLERY_LOAD_LIMIT) {
            return -1;
        }
        return index % GALLERY_LOAD_LIMIT;
    }
    
    func clearAssetList() {
        assetLoadedCount = 0;
        for index in 0..<GALLERY_LOAD_LIMIT {
            currentAssets[index].assetImg = nil;
            currentAssets[index].thumbnail = nil;
            currentAssets[index].highlighted = -1;
        }
    }
    func rehighlightCells() { // used when load photos from albums directly in circular buffer way
        for (loc, check: ImageIndex) in enumerate(self.highlightOrder) { // assign highlight order
            if (check.groupNum == self.groupSelected) {
                let assetIndex = realIndexToAssetArrayIndex(check.index)
                if (assetIndex != -1) {
                    //self.currentAssets[assetIndex].highlighted = loc;
                    self.highlightOrder[loc].assetImg = self.currentAssets[assetIndex].assetImg
                }
            }
        }
    }
    
    // reloads images from start
    func loadImagesForCurrent() {
        NSLog("Selecting \(groupSelected) : \(assetGroups.count)")
        //resets view to be empty for user
        clearAssetList();
        self.myCollectionView.reloadData();
        loadImagesFromGallery(true);
    }
    
    func loadImagesFromGallery(forwards: Bool) {
        //fills up collection view
        //var firstDate = NSDate();
        //imageRenderDirection = 0;
        
        if (loadingAssets) {
            NSLog("Already loading");
            return;
        }
        loadingAssets = true;
        NSLog("Loading \(forwards) up");
        
        var numAssets = assetGroups[groupSelected].numberOfAssets();
        totalAssetsHere = numAssets;
        var numToLoad = GALLERY_LOAD_COUNT;
        var assetStart: Int = 0;
        NSLog("\(numAssets) images total");
        
        //invalidate array indices
        if (forwards) { NSLog("forwards \(assetLoadedCount)")
            assetStart = assetLoadedCount;
            assetLoadedCount += GALLERY_LOAD_COUNT; NSLog("assetLoadedCount \(assetLoadedCount)")
            if (assetLoadedCount > numAssets) {
                numToLoad = GALLERY_LOAD_COUNT - (assetLoadedCount - numAssets);
            }
        }
        else {
            assetLoadedCount -= GALLERY_LOAD_COUNT;
            if (assetLoadedCount < 0) {
                assetLoadedCount = 0;
            }
            var assetStart = assetLoadedCount - GALLERY_LOAD_LIMIT;
            if (assetStart < 0) {
                assetStart = 0;
            }
            if (assetStart + GALLERY_LOAD_COUNT > numAssets) {
                numToLoad = numAssets - assetStart;
            }
        }
        NSLog("start num: \(assetStart), numToLoad: \(numToLoad)!")
        if (numToLoad > photosPerPage) {
            numToLoad = photosPerPage
        }
        var rangeLoad: NSRange = NSMakeRange(assetStart, numToLoad);
        
        NSLog("Loading from \(rangeLoad.location), \(rangeLoad.length) images total");
        
        for arrayAllIndex in 0..<photosPerPage { //GALLERY_LOAD_LIMIT {
            self.currentAssets[arrayAllIndex].highlighted = -1;
        }
        NSLog("pass highlighting initialization")
        for (loc, check: ImageIndex) in enumerate(self.highlightOrder) { // assign highlight order
            if (check.groupNum == self.groupSelected) {
                let assetIndex = realIndexToAssetArrayIndex(check.index)
                if (assetIndex != -1) { NSLog("loc: %d", loc)
                    self.currentAssets[assetIndex].highlighted = loc;
                }
            }
        }
        NSLog("pass highlight order assignment with asset loaded num: \(assetLoadedCount)")
        
        var totalEnumerated: Int = 0;
        var reloadAtIndexPaths: Array<NSIndexPath> = [];
        //enumerateAssetsAtIndexes:options:usingBlock:
        var currentGroup = assetGroups[groupSelected];
        NSLog("pass current group assignment")
        currentGroup.enumerateAssetsAtIndexes(NSIndexSet(indexesInRange: rangeLoad), options: NSEnumerationOptions.Concurrent, usingBlock: {
            (result: ALAsset!, index: Int, stop) in
            if ((result) == nil) {
                NSLog("No result found \(index)");
                totalEnumerated++;
                if (totalEnumerated == numToLoad) {
                    NSLog("Done fetching all!");
                    self.rehighlightCells()
                    self.loadingAssets = false;
                }
                return;
            }
            if (index == 0) { NSLog("index is 0")
                var assetImg = UIImage(CGImage: result.defaultRepresentation().fullResolutionImage().takeUnretainedValue())!;
                self.backImageView.setImageAndBlur(assetImg);
                //firstDate = result.valueForProperty(ALAssetPropertyDate) as NSDate;
            }
            /*else if (index == 1) {
                var secondDate = result.valueForProperty(ALAssetPropertyDate) as NSDate;
                if (firstDate.compare(secondDate) == NSComparisonResult.OrderedAscending) {
                    self.imageRenderDirection = -1;
                    //self.currentAssets[numAssets - 1].asset = self.currentAssets[0].asset
                }
                else if (firstDate.compare(secondDate) == NSComparisonResult.OrderedDescending) {
                    //direction is right
                    self.imageRenderDirection = 1;
                }
            }*/
            var arrayIndex = self.realIndexToAssetArrayIndex(index);NSLog("index at \(index)")
            //NSLog("Getting image \(index) which is at array \(arrayIndex)");
            if (arrayIndex != -1) {
                if ((result) != nil) {
                    self.currentAssets[arrayIndex].assetImg = UIImage(CGImage: result.defaultRepresentation().fullResolutionImage().takeUnretainedValue());
                    self.currentAssets[arrayIndex].thumbnail = UIImage(CGImage: result.thumbnail().takeUnretainedValue()); NSLog("set image and thumbnail at array index \(arrayIndex)")
                }
                //reloadAtIndexPaths.append(NSIndexPath(forRow: arrayIndex+1, inSection: 0));
            }
            self.reconfigureCells(index);
            totalEnumerated++;
            if (totalEnumerated == numToLoad) {
                NSLog("Done fetching all!");
                self.rehighlightCells()
                self.loadingAssets = false;
            }; NSLog("pass loading photos")
            /*else if (reloadAtIndexPaths.count > 10) {
                //reload table every 10
                self.myCollectionView.reloadItemsAtIndexPaths(reloadAtIndexPaths);
                reloadAtIndexPaths = [];
            }*/
            });
    }
    func reconfigureCells(realIndex: Int) { // used when load photos from albums directly in circular buffer way
        for path : AnyObject in myCollectionView.indexPathsForVisibleItems() {
            let index = (path as NSIndexPath).row;
            if (index == realIndex) {
                var cell: PreviewCollectionViewCell = myCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as PreviewCollectionViewCell;
                if (index > 0) {
                    //do stuff with cell
                    configureCell(cell, index: realIndex);
                }
            }
        }
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
        var attrString = NSAttributedString(string: returnLine, attributes: [NSForegroundColorAttributeName: TITLE_TEXT_COLOR, NSFontAttributeName: TABLE_CELL_FONT]);
        return attrString;
    }
    /*func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        //do nothing
    }*/
    func switchViewsFromOptionsTo(row: Int) {
        self.showingOptions = false;
        if (row >= assetGroups.count) {
            for (index, item) in enumerate(currentAssets) {
                //currentAssets[index] = AssetItem(asset: currentAssets[index].asset, highlighted: -1);
                currentAssets[index].highlighted = -1;
            }
            highlightOrder = [];
            optionsView.hidden = true;
            myCollectionView.reloadData();
            return;
        }
        groupSelected = row;
        loadImagesForCurrent();
        myCollectionView.setContentOffset(CGPointZero, animated: false);
        optionsView.hidden = true;
        var name = getGalleryFullName(row) + " ▾";
        self.navigationTitle.setTitle(name, forState: UIControlState.Normal);
    }
    //--------collectionview methods------------
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int  {
        return  1 // (totalAssetsHere + 1) / photosPerPage;
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalAssetsHere // totalAssetsHere + 1 // photosPerPage;
    }
    func configureCell(cell: PreviewCollectionViewCell, index: Int) { // used when load photos from albums directly in circular buffer way
        let assetIndex = realIndexToAssetArrayIndex(index); NSLog("config cell::asset index: \(assetIndex)")
        if (assetIndex == -1) {
            NSLog("This shouldn't happen, like ever");
            return;
        }
        if (self.currentAssets[assetIndex].assetImg == nil) {
            cell.label.text = "";
            cell.image.image = UIImage();
            return;
        }
        cell.image.image = self.currentAssets[assetIndex].thumbnail;
        if (self.currentAssets[assetIndex].highlighted != -1) { // selected photo
            //cell.backgroundColor = UIColor.yellowColor();
            cell.darkenImage();
            var locIndex = find(highlightOrder, ImageIndex(groupNum: groupSelected, index: index, assetImg: self.currentAssets[assetIndex].assetImg));
            if (locIndex != nil) {
                cell.label.text = String(locIndex! + 1);   //for those damn nonprogrammer people
            }
            else {
                cell.label.text = "?!?";   //for those damn nonprogrammer people
            }
            
        }
        else { // unselected photo
            //cell.backgroundColor = UIColor.redColor();
            cell.makeVisible();
            cell.label.text = "";
        }

    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        var cell: PreviewCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as PreviewCollectionViewCell;
        var row = indexPath.row
 /*
        if (row == 0) {
            //render a camera icon
            //cell.backgroundColor = UIColor.redColor();
            cell.makeVisible();
            cell.label.text = "";
            cell.image.image = CAMERA_ICON;
            return cell;
        }
       row--;

        cell.label.text = "";
        
        let assetIndex = realIndexToAssetArrayIndex(row); NSLog("popout cell::asset index: \(assetIndex)")
        if (assetIndex == -1) {
            //not loaded!
            /*if (row >= assetLoadedCount) {
                loadImagesFromGallery(true);
            }
            else {
                loadImagesFromGallery(false);
            }*/
            cell.image.image = UIImage();
            //cell.makeVisible();
            return cell;
        }
        configureCell(cell, index: row);
        if (assetLoadedCount - row < 7) {
            //prefetch images
            loadImagesFromGallery(true);
        }
        else if (row - (assetLoadedCount - GALLERY_LOAD_LIMIT) < 7) {
            loadImagesFromGallery(false);
        }
*/
        
        // pick multiple photos, uncomment the above lines if restore to pick from albums in circular buffer way
        configCell(cell, index: row)
        return cell;
    }
    
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!)  {
        var row = indexPath.row;
/*
        if (row == 0) {
            //open camera
            cameraAction();
            return;
        }
        row--;
        /*if(imageRenderDirection == -1) {
            row = self.currentAssets.count - 1 - row;
        }*/
        
        let assetIndex = realIndexToAssetArrayIndex(row);
*/
        let assetIndex = row
        if (assetIndex == -1) {
            //uh this cell doesn't exist
            NSLog("Selected a cell that shouldn't have been rendered!");
            return;
        }
        
        if (self.currentAssets[assetIndex].highlighted == -1) {
            //needs to be highlighted
            var assetItem: AssetItem =  self.currentAssets[assetIndex];
            assetItem.highlighted = highlightOrder.count;
            self.currentAssets[assetIndex] = assetItem;
            highlightOrder.append(ImageIndex(groupNum: groupSelected, index: row, assetImg: self.currentAssets[assetIndex].assetImg));
        }
        else {
            //unhighlight
            var loc = find(highlightOrder, ImageIndex(groupNum: groupSelected, index: row, assetImg: nil));
            highlightOrder.removeAtIndex(loc!);
            var assetItem: AssetItem =  self.currentAssets[assetIndex];
            assetItem.highlighted = -1;
            self.currentAssets[assetIndex] = assetItem;
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
                                            self.highlightOrder[index] = ImageIndex(groupNum: self.savedPhotoIndex, index: imageIndex.index + 1, assetImg: UIImage(CGImage: asset!.defaultRepresentation().fullResolutionImage().takeUnretainedValue()));
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
//        optionsView.hidden = false;
//        self.showingOptions = true;
        
        // pick multiple photos, uncomment the above lines if restore to pick from albums in circular buffer way
        self.loadPhotos()
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
        var assetImg: UIImage;
        for index:ImageIndex in highlightOrder {
            groupSelected = index.groupNum;
            row = index.index;
            assetImg = index.assetImg!; //self.currentAssets[row];
            retList.append(assetImg);
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
            currentAssets[index].highlighted = -1;
        }
        for (index, item) in enumerate(highlightOrder) {
            if (item.groupNum == groupSelected) {
                let assetIndex = realIndexToAssetArrayIndex(item.index);
                if (assetIndex != -1) {
                    currentAssets[assetIndex].highlighted = index;
                }
            }
        }
        //loadImagesForCurrent();
        myCollectionView.reloadData();
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
    
    // used when picking certain number photos from an album
    func loadPhotos() {
        var picker : CTAssetsPickerController = CTAssetsPickerController()
        picker.assetsFilter = ALAssetsFilter.allPhotos()
        picker.showsCancelButton = (UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad)
        picker.delegate = self
        picker.selectedAssets = NSMutableArray(array: self.photos as NSArray)
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        if (self.popover != nil) {
            self.popover.dismissPopoverAnimated(true)
        } else {
            picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.photos = assets as [ALAsset]!
        self.totalAssetsHere = assets.count
        var arrayIndex = 0
        for index in 0..<assets.count {
            arrayIndex = self.realIndexToAssetArrayIndex(index)
            self.currentAssets[index].assetImg = UIImage(CGImage: photos[index].defaultRepresentation().fullResolutionImage().takeUnretainedValue());
            self.currentAssets[index].thumbnail = UIImage(CGImage: photos[index].thumbnail().takeUnretainedValue());
            self.reconfigCells(index)
        }
        self.rehighlightCells2()
        self.myCollectionView.reloadData();
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldShowAssetsGroup group: ALAssetsGroup!) -> Bool {
        return group.numberOfAssets() > 0
    }
    
    func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: ALAsset!) -> Bool {
        if (picker.selectedAssets.count >= photosPerPage) {
            var alertView : UIAlertView = UIAlertView()
            alertView.title = "Attention"
            alertView.message = "Please select not more than \(photosPerPage) assets"
            alertView.delegate = nil
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        if (asset.defaultRepresentation() == nil) {
            var alertView : UIAlertView = UIAlertView()
            alertView.title = "Attention"
            alertView.message = "Your asset has not yet been downloaded to your device"
            alertView.delegate = nil
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        return (picker.selectedAssets.count < photosPerPage && asset.defaultRepresentation() != nil);
    }
    
    func configCell(cell: PreviewCollectionViewCell, index: Int) { // used when picking certain number photos from an album
        if (index == -1) {
            NSLog("This shouldn't happen, like ever");
            return;
        }
        if (self.currentAssets[index].assetImg == nil) {
            cell.label.text = "";
            cell.image.image = UIImage();
            return;
        }
        cell.image.image = self.currentAssets[index].thumbnail;
        if (self.currentAssets[index].highlighted != -1) { // selected photo
            cell.darkenImage();
            var locIndex = find(highlightOrder, ImageIndex(groupNum: groupSelected, index: index, assetImg: self.currentAssets[index].assetImg));
            if (locIndex != nil) {
                cell.label.text = String(locIndex! + 1);   //for those damn nonprogrammer people
            }
            else {
                cell.label.text = "?!?";   //for those damn nonprogrammer people
            }
            
        } else { // unselected photo
            cell.makeVisible();
            cell.label.text = "";
        }
        
    }
    
    func reconfigCells(realIndex: Int) { // used when picking certain number photos from an album
        for path : AnyObject in myCollectionView.indexPathsForVisibleItems() {
            let index = (path as NSIndexPath).row;
            if (index == realIndex) {
                var cell: PreviewCollectionViewCell = myCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as PreviewCollectionViewCell;
                //do stuff with cell
                configCell(cell, index: realIndex);
            }
        }
    }
    
    func rehighlightCells2() { // used when picking certain number photos from an album
        for (loc, check: ImageIndex) in enumerate(self.highlightOrder) { // assign highlight order
            if (check.groupNum == self.groupSelected) {
                let assetIndex = check.index
                self.currentAssets[assetIndex].highlighted = loc
                self.highlightOrder[loc].assetImg = self.currentAssets[assetIndex].assetImg
            }
        }
    }
    
    func receiveImage(assets: [AnyObject]!) {
        self.photos = assets as [ALAsset]!
        self.totalAssetsHere = assets.count
        for index in 0..<assets.count {
            self.currentAssets[index].assetImg = UIImage(CGImage: photos[index].defaultRepresentation().fullResolutionImage().takeUnretainedValue());
            self.currentAssets[index].thumbnail = UIImage(CGImage: photos[index].thumbnail().takeUnretainedValue());
        }
    }
}

