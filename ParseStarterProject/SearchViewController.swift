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

        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
        
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController.navigationBar.shadowImage = UIImage();
        self.navigationController.navigationBar.translucent = true;
        self.navigationController.view.backgroundColor = UIColor.clearColor();
        self.navigationController.navigationBar.topItem.title = "Popular";
        //self.navigationTitle.setTitle("Popular", forState: UIControlState.Normal);

        // Do any additional setup after loading the view.
        
        myTable.hidden = true;
        
        collectionDelegateMain = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction2: ServerInteractor.getExplore, sender: self);
        if (currentTerm != "") {
            startSearch(currentTerm);
        }
        else {
            collectionDelegateMain!.initialSetup();
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var id: String = segue!.identifier;
        
        if (id == "SearchSegue") {
            
            let temp: Int = myTable.indexPathForSelectedRow().row;
            
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
                self.navigationController.navigationBar.topItem.title = "Search";
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
                self.navigationController.navigationBar.topItem.title = "Search";
            }
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
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (currentTerm == "") {
            return 0;
        }
        return 1 + searchTermList.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as UITableViewCell
        
        var index: Int = indexPath.row;
        
        if (index == 0) {
            cell.textLabel.text = "Search for \"" + currentTerm + "\"!";
            cell.textLabel.textColor = UIColor.whiteColor();
        }
        else {
            if (index - 1 < searchTermList.count) {
                //to avoid race conditions
                cell.textLabel.text = searchTermList[index - 1];
                cell.textLabel.textColor = UIColor.whiteColor();
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        var searchResult: String = "";
        if (index == 0) {
            searchResult = currentTerm;
        }
        else {
            searchResult = searchTermList[indexPath.row - 1];
        }
        startSearch(searchResult);
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
    }
    func startSearch(searchResult: String) {
        //starts a search with a term
        currentTerm = searchResult;
        searchBar.text = searchResult;  //set the search bar to match the search query
        //self.navigationController.navigationBar.topItem.title = searchResult;
        self.title = searchResult;
        doingSearch = 2;
        myTable.hidden = true;
        myCollectionView.hidden = false;
        
        //change context to searching for term
        if (collectionDelegateSearch == nil) {
            collectionDelegateSearch = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction3: ServerInteractor.getSearchPosts, sender: self);
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
}
