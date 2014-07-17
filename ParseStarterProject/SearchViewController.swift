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
    
    var currentTerm: String = "";
    var searchTermList: Array<String> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            
            NSLog("true? \(segue!.destinationViewController is SearchResultsController)")

            //tell my search result controller to receive item
            var controller = segue!.destinationViewController as SearchResultsController;
            
            
            if (temp == 0) {
                controller.receiveSearchTerm(currentTerm);
            }
            else {
                controller.receiveSearchTerm(searchTermList[temp - 1]);
            }
        }
    }
    
    //------------search bar functions---------------
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        currentTerm = searchText;
        
        
        //start a query for the searchText
        receiveSizeOfQuery(0);//erase this line later
        ServerInteractor.getSearchTerms(currentTerm, receiveSizeOfQuery, receiveStringResult, endStringQuery);
    }
    func receiveSizeOfQuery(size: Int){
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
            cell.textLabel.text = searchTermList[index - 1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        self.performSegueWithIdentifier("SearchSegue", sender: self);
    }
    
}
