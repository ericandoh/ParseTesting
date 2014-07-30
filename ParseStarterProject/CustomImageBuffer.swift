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
            loadedUpTo = 0;
            hitEnd = true;
            endLoadCount = 0;
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
                loadedUpTo = 0;
                hitEnd = true;
                endLoadCount = 0;
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
                loadedUpTo = 0;
                hitEnd = true;
                endLoadCount = 0;
            }
            else {
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
        if (isLoading) {
            return;
        }
        isLoading = true;
        //loadedUpTo += 1;
        //loadedPosts += Array<ImagePostStructure?>(count: postLoadCount, repeatedValue: nil);
        //start loading next set of postLoadCount here
        //ServerInteractor.getSubmissions()...; with receiveNumQuery, receiveImagePostWithImage
        //broke here
        
        if (loaderType == 0) {
            serverFunction!(skip: (loadedUpTo)*postLoadCount, loadCount: postLoadCount, user: user!, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
        else if (loaderType == 1) {
            var otherExcludes: Array<ImagePostStructure?> = loadedPosts;
            serverFunction2!(loadCount: postLoadCount, excludes: otherExcludes, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
        else if (loaderType == 2) {
            serverFunction3!(skip: (loadedUpTo)*postLoadCount, loadCount: postLoadCount, term: searchTerm, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
        }
    }
    func resetData() {
        loadedPosts = [];
        loadedUpTo = 0;
        endLoadCount = 0;
        hitEnd = false;
        isLoading = false;
    }
    func getImagePostAt(index: Int)->ImagePostStructure {
        return loadedPosts[index]!;
    }
    func isLoadedAt(index: Int)->Bool {
        if (index >= loadedPosts.count) {
            return false;
        }
        if (loadedPosts[index]) {
            return true;
        }
        return false;
    }
    func didHitEnd()->Bool {
        return hitEnd;
    }
    func receiveNumQuery(size: Int) {
        var needAmount: Int;
        if (size < postLoadCount) {
            hitEnd = true;
            endLoadCount = size;
            needAmount = (loadedUpTo * postLoadCount) + endLoadCount;
        }
        else {
            endLoadCount = 0;
            loadedUpTo += 1;
            needAmount = loadedUpTo * postLoadCount;
        }
        if (loadedPosts.count < needAmount) {
            loadedPosts += Array<ImagePostStructure?>(count: needAmount - loadedPosts.count, repeatedValue: nil);
        }
        //myCollectionView.reloadData();
        if (refreshFunction) {
            refreshFunction!();
        }
    }
    
    func receiveImagePostWithImage(loaded: ImagePostStructure, index: Int) {
        //called by getSubmissions for when image at index x is loaded in...
        var realIndex: Int;
        if (hitEnd) {
            realIndex = index + (loadedUpTo * postLoadCount);
        }
        else {
            realIndex = index + ((loadedUpTo - 1) * postLoadCount);
        }
        loadedPosts[realIndex] = loaded;
        
        self.configureCellFunction!(index: realIndex);
        
        
        isLoading = false;  //still loading cells in, but setting indexes are ok
    }
    func numItems() -> Int {
        return loadedUpTo * postLoadCount + endLoadCount;
    }
    
}
