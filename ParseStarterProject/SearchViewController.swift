//
//  SearchViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/16/14.
//
//

import UIKit
class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var myTable: UITableView;
    @IBOutlet var myCollectionView: UICollectionView
    @IBOutlet var searchBar: UISearchBar
    
    var currentTerm: String = "";
    var searchTermList: Array<String> = [];
    
    var collectionDelegateSearch: ImagePostCollectionDelegate?;
    var collectionDelegateMain: ImagePostCollectionDelegate?;
    
    var doingSearch: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.navigationController.respondsToSelector("interactivePopGestureRecognizer")) {
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
        }
        // Do any additional setup after loading the view.
        
        myTable.hidden = true;
        
        collectionDelegateMain = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction2: ServerInteractor.getPost, sender: self);
        collectionDelegateMain!.initialSetup();
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
            if (collectionDelegateSearch) {
                collectionDelegateSearch!.resetData();
            }
            collectionDelegateMain!.resetData();
            collectionDelegateMain!.initialSetup();
        }
        if (doingSearch && searchText == "") {
            doingSearch = false;
            myTable.hidden = true;
            myCollectionView.hidden = false;
            //add animations here;
        }
        else if (!doingSearch && searchText != "") {
            doingSearch = true;
            myTable.hidden = false;
            myCollectionView.hidden = true;
            if (collectionDelegateSearch) {
                collectionDelegateSearch!.resetData();
            }
            collectionDelegateMain!.resetData();
            //add animations here
            
            
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
        }
        else {
            if (index - 1 < searchTermList.count) {
                //to avoid race conditions
                cell.textLabel.text = searchTermList[index - 1];
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
            searchBar.text = searchResult;
        }
        //update my collectionviewdelegate to instead do a search
        
        doingSearch = false;
        myTable.hidden = true;
        myCollectionView.hidden = false;
        
        //change context to searching for term
        if (!collectionDelegateSearch) {
            collectionDelegateSearch = ImagePostCollectionDelegate(disableOnAnon: false, collectionView: self.myCollectionView, serverFunction3: ServerInteractor.getSearchPosts, sender: self);
        }
        collectionDelegateSearch!.setSearch(searchResult);
        //collectionDelegateSearch!.resetData();
        //collectionDelegateMain!.resetData();
        collectionDelegateSearch!.initialSetup();
        
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
    }
    
}
