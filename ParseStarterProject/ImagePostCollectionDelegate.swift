//
//  ImagePostCollectionDelegate.swift
//  ParseStarterProject
//
//  Delegate object that displays collection view of images and segues to a home-feed like view if clicked on
//
//  Used: User Profile (liked, posts), Search (popular, search results)
//
//  Created by Eric Oh on 7/29/14.
//
//

import UIKit

let COLLECTION_OWNER = "COLLECTION";

class ImagePostCollectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var myCollectionView: UICollectionView;
    
    var owner: UIViewController;
    
    var serverFunction: ((skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var serverFunction2: ((loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var serverFunction3: ((skip: Int, loadCount: Int, term: String, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var imgBuffer: CustomImageBuffer;

    var searchTerm: String = "";    //for search term collections only
    
    //for when you hit end of scroll + want to load more, dont send more requests if I've already made such a request
    var requestedBuffer: Bool = false;
    
    //whether I should mark posts as being read (and possibly mark them as being so)
    var readMode: Bool = false;
    
    var lastThoughtEnd: Int = 0;
    
    var needAddMore:Bool = false;
    
    var myFinishFunction: (()->Void)?;
    
    var imageDelegateIdentifier: Int = random();
    
    /*
        Sample Usage:
        -In viewDidLoad-
            var cdel = ImagePostCollectionDelegate(true, collectionView: self.myCollectionView, ServerInteractor.getPost, self);
            cdel.initialSetup();
    */
    //for user profile stuff
    init(disableOnAnon: Bool, collectionView: UICollectionView,
        serverFunction: (skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void, sender: UIViewController, user: FriendEncapsulator?) {
        
        self.myCollectionView = collectionView;
        self.owner = sender;
        self.serverFunction = serverFunction;
            self.imgBuffer = CustomImageBuffer(disableOnAnon: disableOnAnon, user: user, owner: COLLECTION_OWNER);
    }
    //for search, when showing popular feeds
    init(disableOnAnon: Bool, collectionView: UICollectionView,
        serverFunction2: (serverFunction: (loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?, sender: UIViewController) {
            
            self.myCollectionView = collectionView;
            self.owner = sender;
            self.serverFunction2 = serverFunction2;
            self.imgBuffer = CustomImageBuffer(disableOnAnon: disableOnAnon, user: nil, owner: COLLECTION_OWNER);
            self.readMode = true;
    }
    init(disableOnAnon: Bool, collectionView: UICollectionView,
        serverFunction3: ((skip: Int, loadCount: Int, term: String, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?, sender: UIViewController) {
            
            self.myCollectionView = collectionView;
            self.owner = sender;
            self.serverFunction3 = serverFunction3;
            self.imgBuffer = CustomImageBuffer(disableOnAnon: disableOnAnon, user: nil, owner: COLLECTION_OWNER);
    }
    
    //call this after init, this triggers it to be active
    func initialSetup() {
        self.myCollectionView.dataSource = self;
        self.myCollectionView.delegate = self;
        
        if (serverFunction != nil) {
            self.imgBuffer.initialSetup(serverFunction, refreshFunction: myRefreshFunction, configureCellFunction: checkConfigCell);
        }
        else if (serverFunction2 != nil) {
            self.imgBuffer.initialSetup2(serverFunction2!, refreshFunction: myRefreshFunction, configureCellFunction: checkConfigCell);
        }
        else if (serverFunction3 != nil) {
            self.imgBuffer.initialSetup3(serverFunction3!, refreshFunction: myRefreshFunction, configureCellFunction: checkConfigCell, term: searchTerm);
        }
    }
    func myRefreshFunction() {
        var refreshStart = imgBuffer.newlyLoadedStart;
        var refreshEnd = imgBuffer.newlyLoadedEnd;
        if (self.myCollectionView.delegate is ImagePostCollectionDelegate && (self.myCollectionView.delegate as ImagePostCollectionDelegate).imageDelegateIdentifier != imageDelegateIdentifier) {
            NSLog("Not supposed to be updating the table!");
            return;
        }
        if (refreshEnd - 1 >= refreshStart) {
            if (lastThoughtEnd < refreshStart) {
                NSLog("Warning: Inconsistent! \(lastThoughtEnd) vs \(refreshStart)")
                refreshStart = lastThoughtEnd;
            }
            var indexPaths: Array<NSIndexPath> = [];
            for i in refreshStart...(refreshEnd-1) {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 0));
            }
            self.myCollectionView.insertItemsAtIndexPaths(indexPaths);
        }
        if (needAddMore) {
            var refreshStart = lastThoughtEnd;
            var refreshEnd = imgBuffer.numItems();
            if (refreshEnd - 1 >= refreshStart) {
                var indexPaths: Array<NSIndexPath> = [];
                for i in refreshStart...(refreshEnd-1) {
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0));
                }
                self.myCollectionView.insertItemsAtIndexPaths(indexPaths);
            }
            needAddMore = false;
        }
        //self.myCollectionView.reloadItemsAtIndexPaths(indexPaths);
        //self.myCollectionView.reloadData();
    }
    func setSearch(term: String) {
        searchTerm = term;
    }
    func resetData() {
        self.imgBuffer.resetData();
        myCollectionView.reloadData();
    }
    func loadSet() {
        if (imgBuffer.owner != COLLECTION_OWNER) {
            imgBuffer.owner = COLLECTION_OWNER;
            imgBuffer.refreshFunction = myRefreshFunction;
            imgBuffer.configureCellFunction = checkConfigCell;
        }
        self.imgBuffer.loadSet();
    }
    
    //configures current cell at index with the appropriate post in loadedPosts
    //assumes post at index is already fetched from server
    func checkConfigCell(index: Int) {
        for path : AnyObject in myCollectionView.indexPathsForVisibleItems() {
            if ((path as NSIndexPath).row == index) {
                var cell: SinglePostCollectionViewCell = myCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as SinglePostCollectionViewCell;
                //do stuff with cell
                configureCell(cell, index: index);
            }
        }
    }
    //configures current cell at index with the appropriate post in loadedPosts
    //assumes post at index is already fetched from server
    func configureCell(cell: SinglePostCollectionViewCell, index: Int) {
        var post: ImagePostStructure = imgBuffer.getImagePostAt(index);
        //configure cell to set image here, etc.
        cell.postLabel.text = "Cell \(index)"
        cell.imageView.image = post.image;
        UIView.animateWithDuration(0.1, animations: {() in
            cell.alpha = 1;
            });
        
        if (!post.read) {
            ServerInteractor.readPost(post);
            post.read = true;
        }
        if (index == 0) {
            if (myFinishFunction != nil) {
                myFinishFunction!();
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        lastThoughtEnd = imgBuffer.numItems();
        return lastThoughtEnd;
    }
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell: SinglePostCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCell", forIndexPath: indexPath) as SinglePostCollectionViewCell;
        
        cell.alpha = 0;
        if (imgBuffer.isLoadedAt(indexPath.row)) {
            //load in cell
            configureCell(cell, index: indexPath.row)
        }
        else {
            //cell will get fetched, wait
            
        }
        
        return cell;
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        //open home feed here
        var newHome = owner.storyboard.instantiateViewControllerWithIdentifier("Home") as HomeFeedController;
        newHome.syncWithImagePostDelegate(self.imgBuffer, selectedAt: indexPath.row);
        owner.navigationController.pushViewController(newHome, animated: true);
    }
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (imgBuffer.didHitEnd()) {
            if (imgBuffer.numItems() == lastThoughtEnd) {
                return;
            }
            else {
                needAddMore = true;
                requestedBuffer = false;
            }
        }
        for path: NSIndexPath in myCollectionView.indexPathsForVisibleItems() as Array<NSIndexPath> {
            if (path.row >= (imgBuffer.numItems() - 1 - CELLS_BEFORE_RELOAD)) {
                if (!requestedBuffer) {
                    requestedBuffer = true;
                    self.loadSet();
                }
                return;
            }
        }
        requestedBuffer = false;
    }
    func getPost()->ImagePostStructure? {
        var indexPaths: [NSIndexPath] = myCollectionView.indexPathsForSelectedItems() as [NSIndexPath];
        if (indexPaths.count > 0) {
            var indexPath: NSIndexPath = indexPaths[0];
            return getPost(indexPath.row);
        }
        return nil;
    }
    func getPost(index: Int)->ImagePostStructure {
        return imgBuffer.getImagePostAt(index);
    }
}
