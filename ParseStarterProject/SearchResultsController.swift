//
//  SearchResultsController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/16/14.
//
//

import UIKit

//Deprecated

/*
let reuseIdentifier = "SearchResultCell"

class SearchResultsController: UICollectionViewController {

    var searchTerm: String = "";
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView.registerClass(SearchCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        self.title = searchTerm;
        
        hitEnd = false;
        //loadedPosts = [];
        loadSet();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveSearchTerm(someTerm: String) {
        searchTerm = someTerm;
    }
    func receiveNumQuery(size: Int) {
        var needAmount: Int;
        if (size < SEARCH_LOAD_COUNT) {
            hitEnd = true;
            endLoadCount = size;
            needAmount = (loadedUpTo * SEARCH_LOAD_COUNT) + endLoadCount;
        }
        else {
            endLoadCount = 0;
            loadedUpTo += 1;
            needAmount = loadedUpTo * SEARCH_LOAD_COUNT;
        }
        if (loadedPosts.count < needAmount) {
            loadedPosts += Array<ImagePostStructure?>(count: needAmount - loadedPosts.count, repeatedValue: nil);
        }
        self.collectionView.reloadData();
    }
    func receiveImagePostWithImage(loaded: ImagePostStructure, index: Int) {
        //called by getSubmissions for when image at index x is loaded in...
        //NSLog("Received image at index \(index)")
        var realIndex: Int;
        if (hitEnd) {
            realIndex = index + (loadedUpTo * SEARCH_LOAD_COUNT);
        }
        else {
            realIndex = index + ((loadedUpTo - 1) * SEARCH_LOAD_COUNT);
        }
        loadedPosts[realIndex] = loaded;
        
        for path : AnyObject in self.collectionView.indexPathsForVisibleItems() {
            if ((path as NSIndexPath).row == realIndex) {
                var cell: SearchCollectionViewCell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: realIndex, inSection: 0)) as SearchCollectionViewCell;
                //do stuff with cell
                configureCell(cell, index: realIndex);
            }
        }
        isLoading = false;  //still loading cells in, but setting indexes are ok
    }

    //configures current cell at index with the appropriate post in loadedPosts
    //assumes post at index is already fetched from server
    func configureCell(cell: SearchCollectionViewCell, index: Int) {
        var post: ImagePostStructure = loadedPosts[index]!;
        //configure cell to set image here, etc.
        cell.postLabel.text = "Cell \(index)"
        cell.imageView.image = post.image;
    }
    
    func loadSet() {
        if (isLoading) {
            return;
        }
        isLoading = true;
        ServerInteractor.getSearchPosts((loadedUpTo)*SEARCH_LOAD_COUNT, loadCount: SEARCH_LOAD_COUNT, term: searchTerm, notifyQueryFinish: receiveNumQuery, finishFunction: receiveImagePostWithImage);
    }
    
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if (segue && segue!.identifier != nil) {
            if (segue!.identifier == "ImagePostSegue") {
                var indexPaths: [NSIndexPath] = collectionView.indexPathsForSelectedItems() as [NSIndexPath];
                if (indexPaths.count > 0) {
                    var indexPath: NSIndexPath = indexPaths[0];
                    (segue!.destinationViewController as ImagePostNotifViewController).receiveImagePost(loadedPosts[indexPath.row]!);
                }
            }
        }
    }

    // #pragma mark UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1;
    }


    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return loadedUpTo * SEARCH_LOAD_COUNT + endLoadCount;
    }

    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        //var cell: SearchCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as SearchCollectionViewCell
    
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as SearchCollectionViewCell;
        
        if (loadedPosts[indexPath.row]) {
            //load in cell
            configureCell(cell, index: indexPath.row)
        }
        else {
            //cell will get fetched, wait
        }
        return cell
    }
    override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        //lastSelect = indexPath!.row;
        self.performSegueWithIdentifier("ImagePostSegue", sender: self);
    }
    override func scrollViewDidScroll(scrollView: UIScrollView!) {
        if (hitEnd) {
            return;
        }
        for path: NSIndexPath in collectionView.indexPathsForVisibleItems() as Array<NSIndexPath> {
            if (path.row == loadedUpTo * SEARCH_LOAD_COUNT + endLoadCount - 1) {
                loadSet();
                return;
            }
        }
    }
}*/
