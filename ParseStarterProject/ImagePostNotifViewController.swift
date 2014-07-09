//
//  ImagePostNotifViewController.swift
//  ParseStarterProject
//
//  Panel to show an image associated with a notification
//
//  Created by Eric Oh on 7/2/14.
//
//

import UIKit

class ImagePostNotifViewController: UIViewController {

    @IBOutlet var postTitle: UILabel
    @IBOutlet var imageView: UIImageView
    //@IBOutlet var commentView: UIView  //use this for hiding and showing


    @IBAction func comments(sender: AnyObject) {
        NSLog("button pushed");
        if (notif) {
            notif!.getComments({(commentary: Array<String>) -> Void in
                for comment in commentary {
                    NSLog(comment);
                }
                });
        }
    }
    
    
    var notif: InAppNotification?;

    //var commentList: Array<PostComment> = [];


    override func viewDidLoad() {
        //second
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (notif) {
            notif!.getImage({(img: UIImage)-> Void in
                self.imageView.image = img;
                });

            //for now, set post title to notification title?
            postTitle.text = notif!.messageString;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    func receiveNotifObject(notification: InAppNotification) {
        //first, notif controller calls this first
        notif = notification;
    }
    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
