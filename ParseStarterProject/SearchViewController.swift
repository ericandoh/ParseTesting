//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/16/14.
//
//

import UIKit
class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var myTable: UITableView!;
    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var backImageView: BlurringDarkView!
    @IBOutlet weak var backButton: UIButton!
    
    var currentTerm: String = "";
    var searchTermList: Array<String> = [];
    
    var collectionDelegateSearch: ImagePostCollectionDelegate?;
    var collectionDelegateMain: ImagePostCollectionDelegate?;
    
    //0 - is looking at popular
    //1 - showing text fields + table
    //2 - showing collection view of search results
    var doingSearch: Int = 0;
    
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
        if (iOS_VERSION > 7.0) {
            searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
        }
        searchBar.resignFirstResponder()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController!.navigationBar.shadowImage = UIImage();
        self.navigationController!.navigationBar.translucent = true;
        self.navigationController!.view.backgroundColor = UIColor.clearColor();
        self.navigationController!.navigationBar.topItem!.title = "Popular";
        
        //self.navigationTitle.setTitle("Popular", forState: UIControlState.Normal);
        self.navigationController!.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;

        // Do any additional setup after loading the view.
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "isTapped:");
        tapRecognizer.cancelsTouchesInView = false;
        self.myTable.addGestureRecognizer(tapRecognizer);
        myTable.hidden = true;
        myTable.tableFooterView = UIView(frame: CGRectZero);
        
        //self.searchBar.barStyle = UIBarStyle.BlackTranslucent
        
        /*self.searchBar.barStyle = UIBarStyle.BlackTranslucent
        // set bar transparancy
        self.searchBar.translucent = true;
        // set bar color
        self.searchBar.barTintColor = UIColor.clearColor()
        // set bar button color
        self.searchBar.tintColor = UIColor.clearColor()
        // set bar background color
        self.searchBar.backgroundColor = UIColor.clearColor()
        self.searchBar.layer.cornerRadius = 3;
        self.searchBar.layer.backgroundColor = UIColor.clearColor().CGColor;
        self.searchBar.layer.borderWidth=0.75;
        self.searchBar.layer.borderColor = UIColor.whiteColor().CGColor*/
        
        
        self.searchBar.translucent = true;
        self.searchBar.tintColor = UIColor.whiteColor()
        self.searchBar.layer.cornerRadius = 3;
        self.searchBar.layer.backgroundColor = UIColor.clearColor().CGColor;
        self.searchBar.layer.borderWidth=0.75;
        self.searchBar.layer.borderColor = UIColor.whiteColor().CGColor
        self.searchBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default);
        var searchBackImg = ServerInteractor.imageWithColorForSearch(UIColor.clearColor(), andHeight: 32);
        self.searchBar.setSearchFieldBackgroundImage(searchBackImg, forState: UIControlState.Normal);
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        if (collectionDelegateMain == nil) {
            collectionDelegateMain = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction2: ServerInteractor.getExplore, sender: self);
            collectionDelegateMain!.myFinishFunction = self.setBackImage;
            if (currentTerm != "") {
                startSearch(currentTerm);
            }
            else {
                collectionDelegateMain!.initialSetup();
            }
        }
        else {
            self.myCollectionView.reloadData();
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(animated: Bool) {
        var cellIndices = myCollectionView.indexPathsForVisibleItems() as Array<NSIndexPath>;
        for cellIndex in cellIndices {
            var cell = myCollectionView.cellForItemAtIndexPath(cellIndex)
            if let exist_cell = cell {
                exist_cell.alpha = 0;
            }
        }
    }

    @IBAction func backPress(sender: UIButton) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count > 1) {
                self.navigationController!.popViewControllerAnimated(true);
            }
        }
    }
    
    @IBAction func sideMenuButtonPress(sender: AnyObject) {
        if ((self.navigationController) != nil) {
            if (self.navigationController!.viewControllers.count >= 1) {
                //this is the only vc on the stack - move to menu
                (self.navigationController!.parentViewController as SideMenuManagingViewController).openMenu();
            }
        }
    }
    /*func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        /*if([searchText length] == 0) {
            [searchBar performSelector: ""(resignFirstResponder)
            withObject: nil
            afterDelay: 0.1];
        }*/
        /*if (currentTerm == "") {
            searchBar.performSelector("keyboardWillHide:"(resignFirstResponder()), withObject: nil, afterDelay: 0.1)
        }*/
    }*/
    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var id: String = segue.identifier!;
        
        if (id == "SearchSegue") {
            
            let temp: Int = myTable.indexPathForSelectedRow()!.row;
            
            //tell my search result controller to receive item
            //var controller = segue!.destinationViewController as SearchResultsController;
            
            
            if (temp == 0) {
               // controller.receiveSearchTerm(currentTerm);
            }
            else {
                //controller.receiveSearchTerm(searchTermList[temp - 1]);
            }
        }
    }
    
    func setBackImage() {
        var mainUser = FriendEncapsulator.dequeueFriendEncapsulatorWithID(PFUser.currentUser().objectId)
        mainUser.fetchImage({(image: UIImage)->Void in
            //self.backImage.image = image;
            var backImg = image
            if backImg == DEFAULT_USER_ICON {
                backImg = DEFAULT_USER_ICON_BACK
            }
            self.backImageView.setImageAndBlur(backImg);
        })
    }
    
    //------------search bar functions---------------
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        if (searchText == "") {
            //no need to do jack when 0
            if (doingSearch == 1) {
                /*if (collectionDelegateSearch) {
                    collectionDelegateSearch!.resetData();
                }*/
                collectionDelegateMain!.resetData();
                collectionDelegateMain!.initialSetup();
                
                doingSearch = 0;
                myTable.hidden = true;
                myCollectionView.hidden = false;
                self.navigationController!.navigationBar.topItem!.title = "Popular";
            }
            else if (doingSearch == 2) {
                /*if (collectionDelegateSearch) {
                    collectionDelegateSearch!.resetData();
                }*/
                collectionDelegateMain!.resetData();
                collectionDelegateMain!.initialSetup();
                
                doingSearch = 0;
                //myTable.hidden = true;
                //myCollectionView.hidden = false;
                //add animations here;
                self.navigationController!.navigationBar.topItem!.title = "Popular";
            }
            searchBar.resignFirstResponder();
            let delay  = 0.1 * Double(NSEC_PER_SEC);
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                var x = searchBar.resignFirstResponder()
                }
            );
            //searchBar.performSelector("hideKeyboardStuff", withObject: self, afterDelay: 0.1);
            
        }
        else if (searchText != "") {
            if (doingSearch == 0) {
                //start a new search
                doingSearch = 1;
                myTable.hidden = false;
                myCollectionView.hidden = true;
                /*if (collectionDelegateSearch) {
                    collectionDelegateSearch!.resetData();
                }
                collectionDelegateMain!.resetData();*/
            }
            else if (doingSearch == 1) {
                //do nothing
            }
            else if (doingSearch == 2) {
                doingSearch = 1;
                myTable.hidden = false;
                myCollectionView.hidden = true;
            }
        }

        currentTerm = searchText;
        
        //start a query for the searchText
        receiveSizeOfQuery(0);//erase this line later
        ServerInteractor.getSearchTerms(currentTerm, receiveSizeOfQuery, receiveStringResult, endStringQuery);
        
    }
    func receiveSizeOfQuery(size: Int) {
        searchTermList = Array<String>(count: size, repeatedValue: "");
        //here or in endStringQuery?
        //myTable.reloadData();
    }
    func receiveStringResult(index: Int, classifier: String) {
        searchTermList[index] = classifier;
    }
    func endStringQuery() {
        myTable.reloadData();
    }
    
    //--------------table view functions------------
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentTerm == "") {
            return 0;
        }
        return 1 + searchTermList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as UITableViewCell
        
        var index: Int = indexPath.row;
        
        if (index == 0) {
            cell.textLabel!.text = "Search for \"" + currentTerm + "\"";
            cell.textLabel!.textColor = UIColor.whiteColor();
            cell.textLabel!.font = TABLE_CELL_FONT;
        }
        else {
            if (index - 1 < searchTermList.count) {
                //to avoid race conditions
                cell.textLabel!.text = searchTermList[index - 1];
                cell.textLabel!.textColor = UIColor.whiteColor();
                cell.textLabel!.font = TABLE_CELL_FONT;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
        }
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        var searchResult: String = "";
        if (index == 0) {
            searchResult = currentTerm;
        }
        else {
            //crashed here
            //maybe array check index out of range
            searchResult = searchTermList[indexPath.row - 1];
        }
        searchBar.resignFirstResponder();
        startSearch(searchResult);
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        startSearch(searchBar.text);
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("Cancel Clicked")
    }
    func startSearch(searchResult: String) {
        //starts a search with a term
        currentTerm = searchResult;
        searchBar.text = searchResult;  //set the search bar to match the search query
        //.self.navigationController!.navigationBar.topItem!.title = searchResult;
        self.title = searchResult;
        doingSearch = 2;
        myTable.hidden = true;
        myCollectionView.hidden = false;
        
        //change context to searching for term
        if (collectionDelegateSearch == nil) {
            collectionDelegateSearch = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction3: ServerInteractor.getSearchPosts, sender: self);
            collectionDelegateSearch!.myFinishFunction = self.setBackImage;
        }
        else {
            collectionDelegateSearch!.resetData();
        }
        //update my collectionviewdelegate to instead do a search
        collectionDelegateSearch!.setSearch(searchResult);
        //collectionDelegateSearch!.resetData();
        collectionDelegateMain!.resetData();
        collectionDelegateSearch!.initialSetup();
    }
    func isTapped(sender: UITapGestureRecognizer) {
        self.searchBar.resignFirstResponder();
    }
}
