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
    /*
    //the posts I have loaded
    var loadedPosts: Array<ImagePostStructure?> = [];
    
    //how many sets I have loaded up to
    var loadedUpTo: Int = 0;
    
    //how many images are loaded in our last set (only valid when hitEnd = true)
    var endLoadCount: Int = 0;
    
    //set to true when I have already loaded in last set of stuff
    var hitEnd: Bool = false;
    
    //isLoading
    var isLoading: Bool = false;
    
    //whether to disable loading if anonymous is logged in
    var disableOnAnon: Bool = false;
    */

    var myCollectionView: UICollectionView;
    
    var owner: UIViewController;
    
    var serverFunction: (skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void;
    /*
    var user: FriendEncapsulator?;
    
    var postLoadCount = MYPOST_LOAD_COUNT;*/
    
    var imgBuffer: CustomImageBuffer;
    
    /*
        Sample Usage:
        -In viewDidLoad-
            var cdel = ImagePostCollectionDelegate(true, collectionView: self.myCollectionView, ServerInteractor.getPosts, self);
            cdel.initialSetup();
    */
    init(disableOnAnon: Bool, collectionView: UICollectionView,
        serverFunction: (skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void, sender: UIViewController, user: FriendEncapsulator?) {
        
        self.myCollectionView = collectionView;
        self.owner = sender;
        self.serverFunction = serverFunction;
            self.imgBuffer = CustomImageBuffer(disableOnAnon: disableOnAnon, user: user, owner: COLLECTION_OWNER);
    }
    
    //call this after init, this triggers it to be active
    func initialSetup() {
        self.myCollectionView.dataSource = self;
        self.myCollectionView.delegate = self;
        
        self.imgBuffer.initialSetup(serverFunction, refreshFunction: {() in self.myCollectionView.reloadData();}, configureCellFunction: checkConfigCell);
    }
    
    func resetData() {
        self.imgBuffer.resetData();
    }
    func loadSet() {
        if (self.owner != COLLECTION_OWNER) {
            imgBuffer.refreshFunction = {() in self.myCollectionView.reloadData();};
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
    }
    
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return imgBuffer.numItems();
    }
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell: SinglePostCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCell", forIndexPath: indexPath) as SinglePostCollectionViewCell;
        
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
        NSLog("Not Yet Implemented!");
        var newHome = owner.storyboard.instantiateViewControllerWithIdentifier("Home") as HomeFeedController;
        newHome.syncWithImagePostDelegate(self.imgBuffer, selectedAt: indexPath.row);
        owner.navigationController.pushViewController(newHome, animated: true);
    }
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (imgBuffer.didHitEnd()) {
            return;
        }
        for path: NSIndexPath in myCollectionView.indexPathsForVisibleItems() as Array<NSIndexPath> {
            if (path.row == imgBuffer.numItems() - 1) {
                imgBuffer.loadSet();
                return;
            }
        }
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
