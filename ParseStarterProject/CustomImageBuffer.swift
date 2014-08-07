//
//  CustomImageBuffer.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/29/14.
//
//

import UIKit

class CustomImageBuffer: NSObject {

    //the posts I have loaded
    var loadedPosts: Array<ImagePostStructure?> = [];
    
    /*
    //how many sets I have loaded up to
    var loadedUpTo: Int = 0;
    
    //how many images are loaded in our last set (only valid when hitEnd = true)
    var endLoadCount: Int = 0;
    */
    
    var loadedPostCount: Int = 0;
    
    //set to true when I have already loaded in last set of stuff
    var hitEnd: Bool = false;
    
    //isLoading
    var isLoading: Int = 0;
    
    //whether to disable loading if anonymous is logged in
    var disableOnAnon: Bool = false;
    
    var serverFunction: ((skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var serverFunction2: ((loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var serverFunction3: ((skip: Int, loadCount: Int, term: String, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?;
    
    var refreshFunction: (()->Void)?;
    
    var configureCellFunction: ((index: Int)->Void)?;
    
    var user: FriendEncapsulator?;
    
    var postLoadCount = POST_LOAD_COUNT;
    
    //whether im loading image posts by exclude or by order (or by search?!?)
    //this does NOT differentiate between home screen or other screens!
    var loaderType: Int = 0;
    
    var owner: String;

    var searchTerm: String = "";
    
    //this variables are only active right after a call to receiveNumQuery
    //used by higher up functions to refresh appropriate sections only
    var newlyLoadedStart: Int = 0;
    var newlyLoadedEnd: Int = 0;
    
    //how many things I should expect to load eventually
    var numLoaded: Int = 0;
    
    //active meaning I should write to the collectionview
    var isActive: Bool = false;
    
    //whenever the buffer is reset, previous calls to functions must be invalidated
    //this variable lets me know (for delayed calls) if my callback is modifying at the correct state 
    //(i.e. callback from old function after I reset gets called, makes sure my state is consistent
    
    init(disableOnAnon: Bool, user: FriendEncapsulator?, owner: String) {
        self.disableOnAnon = disableOnAnon;
        self.user = user;
        hitEnd = false;
        self.owner = owner;
        //loadedPosts = [];
    }
    func initialSetup(serverFunction: ((skip: Int, loadCount: Int, user: FriendEncapsulator, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?,
        refreshFunction: ()->Void,
        configureCellFunction: (index: Int)->Void) {
        
        self.loaderType = 0;        //loads already existing arrays in order
        self.serverFunction = serverFunction;
        self.refreshFunction = refreshFunction;
        self.configureCellFunction = configureCellFunction;

        if (disableOnAnon && ServerInteractor.isAnonLogged()) {
            //loadedUpTo = 0;
            hitEnd = true;
            //endLoadCount = 0;
            loadedPostCount = 0;
        }
        else {
            loadSet();
        }
    }
    func initialSetup2(serverFunction: (loadCount: Int, excludes: Array<ImagePostStructure?>, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void,
        refreshFunction: (()->Void)?,
        configureCellFunction: (index: Int)->Void) {
            
            self.loaderType = 1;        //loads already existing arrays in order
            self.serverFunction2 = serverFunction;
            self.refreshFunction = refreshFunction;
            self.configureCellFunction = configureCellFunction;
            if (disableOnAnon && ServerInteractor.isAnonLogged()) {
                //loadedUpTo = 0;
                hitEnd = true;
                //endLoadCount = 0;
                loadedPostCount = 0;
            }
            else {
                loadSet();
            }
    }
    func initialSetup3(serverFunction: ((skip: Int, loadCount: Int, term: String, notifyQueryFinish: (Int)->Void, finishFunction: (ImagePostStructure, Int)->Void)->Void)?,
        refreshFunction: (()->Void)?,
        configureCellFunction: (index: Int)->Void,
        term: String
        ) {
            
            self.loaderType = 2;        //loads a search term with the thing
            self.serverFunction3 = serverFunction;
            self.refreshFunction = refreshFunction;
            self.configureCellFunction = configureCellFunction;
            self.searchTerm = term;
            if (disableOnAnon && ServerInteractor.isAnonLogged()) {
                //loadedUpTo = 0;
                hitEnd = true;
                //endLoadCount = 0;
                loadedPostCount = 0;
            }
            else {
                loadSet();
            }
    }
    func initialSetup4(refreshFunction: (()->Void)?,
        configureCellFunction: (index: Int)->Void,
        alreadyLoadedPosts: Array<ImagePostStructure?>
        ) {
            
            self.loaderType = 3;        //loads a search term with the thing
            self.refreshFunction = refreshFunction;
            self.configureCellFunction = configureCellFunction;
            if (disableOnAnon && ServerInteractor.isAnonLogged()) {
                //loadedUpTo = 0;
                hitEnd = true;
                //endLoadCount = 0;
                loadedPostCount = 0;
            }
            else {
                self.loadedPosts = alreadyLoadedPosts;
                loadSet();
            }
    }
    func switchContext(owner: String,
        refreshFunction: (()->Void)?,
        configureCellFunction: (index: Int)->Void) {
        self.owner = owner;
        self.refreshFunction = refreshFunction
        self.configureCellFunction = configureCellFunction;
    }
    func loadSet() {
        NSLog("Buffer loading")
        if (isLoading != 0) {
            NSLog("Inconsistent: \(isLoading) != 0")
            return;
        }
        isLoading = 1;
        isActive = true;
        //loadedUpTo += 1;
        //loadedPosts += Array<ImagePostStructure?>(count: postLoadCount, repeatedValue: nil);
        //start loading next set of postLoadCount here
        //ServerInteractor.getSubmissions()...; with receiveNumQuery, receiveImagePostWithImage
        //broke here
        
        if (loaderType == 0) {
            serverFunction!(skip: loadedPostCount, loadCount: postLoadCount, user: user!, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
        else if (loaderType == 1) {
            var otherExcludes: Array<ImagePostStructure?> = loadedPosts;
            serverFunction2!(loadCount: postLoadCount, excludes: otherExcludes, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
        else if (loaderType == 2) {
            serverFunction3!(skip: loadedPostCount, loadCount: postLoadCount, term: searchTerm, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
        else if (loaderType == 3) {
            //everything (should) already be loaded
            hitEnd = true;
            isLoading = 0;
            loadedPostCount = loadedPosts.count;
            //endLoadCount = (loadedPosts.count) % postLoadCount;
            //var divisible = loadedPosts.count - endLoadCount;
            //loadedUpTo = divisible / postLoadCount;
            if (refreshFunction != nil) {
                refreshFunction!();
            }
            for realIndex in 0...self.loadedPosts.count {
                self.configureCellFunction!(index: realIndex);
            }
        }
    }
    func resetData() {
        if (loaderType != 3) {
            loadedPosts = [];
        }
        //loadedUpTo = 0;
        //endLoadCount = 0;
        loadedPostCount = 0;
        hitEnd = false;
        isLoading = 0;
        isActive = false;
    }
    func getImagePostAt(index: Int)->ImagePostStructure {
        return loadedPosts[index]!;
    }
    func isLoadedAt(index: Int)->Bool {
        if (index >= loadedPosts.count || index < 0) {
            return false;
        }
        if (loadedPosts[index] != nil) {
            return true;
        }
        return false;
    }
    func didHitEnd()->Bool {
        return hitEnd;
    }
    func receiveNumQuery(size: Int) {
        NSLog("Received results \(size)")
        if (isLoading != 1) {
            NSLog("Inconsistent: \(isLoading) != 1")
            return;
        }
        isLoading = 2;
        
        newlyLoadedStart = loadedPosts.count;
        
        var needAmount: Int;
        if (size == 0) {
            hitEnd = true;
        }
        else {
            //size must equal postLoadCount
            //endLoadCount = 0;
            //loadedUpTo += 1;
            //needAmount = loadedUpTo * postLoadCount;
            loadedPostCount = size + loadedPostCount;
            loadedPosts += Array<ImagePostStructure?>(count: size, repeatedValue: nil);
        }
        newlyLoadedEnd = loadedPosts.count;
        numLoaded = size;
        //myCollectionView.reloadData();
        if (refreshFunction != nil) {
            if (isActive) {
                refreshFunction!();
            }
        }
    }
    
    func receiveImagePostWithImage(loaded: ImagePostStructure, index: Int) {
        //called by getSubmissions for when image at index x is loaded in...
        if (isLoading != 2) {
            NSLog("Inconsistent: \(isLoading) != 2")
            return;
        }
        var realIndex: Int;
        //if (hitEnd) {
        realIndex = index + newlyLoadedStart;
        /*}
        else {
            realIndex = index + ((loadedUpTo - 1) * postLoadCount);
        }*/
        loadedPosts[realIndex] = loaded;
        
        if (isActive) {
            self.configureCellFunction!(index: realIndex);
        }
        
        numLoaded--;
        if (numLoaded == 0) {
            isLoading = 0;
        }
        //isLoading = false;  //still loading cells in, but setting indexes are ok
    }
    func numItems() -> Int {
        return loadedPostCount;
        //return loadedUpTo * postLoadCount + endLoadCount;
    }
    
}
