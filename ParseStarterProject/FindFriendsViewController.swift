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
    var searchTermList: Array<FriendEncapsulator?> = [];
    var currentTerm: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*someTextField.owner = self;
        
        someTextField.setTextAfterAttributing("spotting the hottest fashion wear of the year #summer #penguin #fun #awesome with my buddies @dog1 @dog2 @asdf @meepmeep #coolbro socool")*/
        
        //self.navigationController.navigationBar.topItem.title = "Find Friends";
        // Do any additional setup after loading the view.
        self.searchFriendsTableView.rowHeight = UITableViewAutomaticDimension;
        self.searchFriendsTableView.estimatedRowHeight = 60.0;
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
        if (!self.isSearching) {
            self.isSearching = true;
            self.searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
        }
        searchTermList = [];
        self.currentTerm = "Friends From Facebook";
        self.searchBar.text = self.currentTerm;
        ServerInteractor.getFBFriendUsers(receiveSizeOfQuery, receiveStringResult, endStringQuery);
    }
    
    @IBAction func findFriendsFromContacts(sender: UIButton) {
        if (!self.isSearching) {
            self.isSearching = true;
            self.searchFriendsTableView.hidden = false;
            self.view.bringSubviewToFront(searchFriendsTableView);
        }
        searchTermList = [];
        self.currentTerm = "Friends From Contacts";
        self.searchBar.text = self.currentTerm;
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
        searchTermList = Array<FriendEncapsulator?>(count: size, repeatedValue: nil);
        //here or in endStringQuery?
        //yTable.reloadData();
    }
    func receiveStringResult(index: Int, classifier: String) {
        searchTermList[index] = FriendEncapsulator.dequeueFriendEncapsulator(classifier);
    }
    func endStringQuery() {
        searchFriendsTableView.reloadData();
    }


    //-------------------tableview methods-------------------
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if (!isSearching) {
            return 0;
        }
        return searchTermList.count;
        //return 1 + searchTermList.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: UserTextTableViewCell = tableView!.dequeueReusableCellWithIdentifier("SearchFriendCell", forIndexPath: indexPath) as UserTextTableViewCell;
        
        // Configure the cell...
        var index: Int = indexPath.row;
        
        if (index < searchTermList.count && searchTermList[index] != nil) {
            //to avoid race conditions
            var author = searchTermList[index]!.username;
            var text = author;
            cell.extraConfigurations(FriendEncapsulator.dequeueFriendEncapsulator(author), message: text, enableFriending: true, sender: self);
        }
        
        
        
        //if (index == 0) {
            //cell.textLabel.text = "Search for user \"" + currentTerm + "\"!";
        //}
        //else {
        
        //}
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        return cell;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var index: Int = indexPath.row;
        var searchResult: String = "";
        var friend: FriendEncapsulator?;
        //if (index == 0) {
            //searchResult = currentTerm;
            //friend = FriendEncapsulator(friendName: searchResult);
        //}
        //else {
        friend = searchTermList[indexPath.row];
        //}
        //startSearch(searchResult);
        //self.performSegueWithIdentifier("SearchSegue", sender: self);
        
        //var friend = FriendEncapsulator(friendName: searchResult);
        friend!.exists({(exist: Bool) in
            if (exist) {
                self.searchBar.text = "";
                self.isSearching = false;
                self.searchTermList = [];
                self.searchFriendsTableView.hidden = true;
                
                var nextBoard : UIViewController = self.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                (nextBoard as UserProfileViewController).receiveUserInfo(friend!);
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
