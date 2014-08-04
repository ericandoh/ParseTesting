//
//  FindFriendsViewController.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/29/14.
//
//

import UIKit

let SUGGESTED_CELL_IDENTIFIER = "SuggestedFriendCell";
let SEARCH_CELL_IDENTIFIER = "SearchFriendCell";

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var suggestedFriendsTableView: UITableView!
    @IBOutlet var searchFriendsTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var isSearching: Bool = false;
    var searchTermList: Array<String> = [];
    var currentTerm: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*someTextField.owner = self;
        
        someTextField.setTextAfterAttributing("spotting the hottest fashion wear of the year #summer #penguin #fun #awesome with my buddies @dog1 @dog2 @asdf @meepmeep #coolbro socool")*/
        
        //self.navigationController.navigationBar.topItem.title = "Find Friends";
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated);
        searchBar.text = "";
        isSearching = false;
        searchTermList = [];
        searchFriendsTableView.hidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func findFriendsFromFB(sender: UIButton) {
    }
    
    @IBAction func findFriendsFromContacts(sender: UIButton) {
        ServerInteractor.getSearchContacts(receiveSizeOfQuery, receiveStringResult, endStringQuery);
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        if (searchText == "") {
            if (isSearching) {
                isSearching = false;
                searchTermList = [];
                searchFriendsTableView.hidden = true;
            }
            return;
        }
        if (!isSearching) {
            isSearching = true;
            //loadFriendList = [];
            searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
        }
        currentTerm = searchText;
        searchTermList = [];
        ServerInteractor.getSearchUsers(searchText, receiveSizeOfQuery, receiveStringResult, endStringQuery);
    }
    func receiveSizeOfQuery(size: Int) {
        searchTermList = Array<String>(count: size, repeatedValue: "");
        //here or in endStringQuery?
        //yTable.reloadData();
    }
    func receiveStringResult(index: Int, classifier: String) {
        searchTermList[index] = classifier;
    }
    func endStringQuery() {
        searchFriendsTableView.reloadData();
    }


    //-------------------tableview methods-------------------
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (!isSearching) {
            return 0;
        }
        return 1 + searchTermList.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = tableView!.dequeueReusableCellWithIdentifier(SEARCH_CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell
        
        var index: Int = indexPath.row;
        
        if (index == 0) {
            cell.textLabel.text = "Search for user \"" + currentTerm + "\"!";
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
        }
        //startSearch(searchResult);
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
        
        var friend = FriendEncapsulator(friendName: searchResult);
        friend.exists({(exist: Bool) in
            if (exist) {
                self.searchBar.text = "";
                self.isSearching = false;
                self.searchTermList = [];
                self.searchFriendsTableView.hidden = true;
                
                var nextBoard : UIViewController = self.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                self.navigationController.pushViewController(nextBoard, animated: true);
            }
            else {
                let alert: UIAlertController = UIAlertController(title: "No user found!", message: "User \(searchResult) does not exist", preferredStyle: UIAlertControllerStyle.Alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                    //canceled
                    }));
                self.presentViewController(alert, animated: true, completion: nil)
            }

        });
        
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
