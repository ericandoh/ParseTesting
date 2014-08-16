//
//  ReportProblemViewController.swift
//  ParseStarterProject
//
//  Created by temp on 8/12/14.
//
//

import Foundation

class ReportProblemViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var backImage: UIImageView!
    
    @IBOutlet weak var reportGuide: UITextView!
    
    @IBOutlet weak var report: UITextView!
    
    @IBOutlet weak var tapBackgroundOutlet: UIButton!
    
    var placeholding: Bool = false;
    var prevDescrip: String = "";
    
    override func viewDidLoad() {
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default);
        self.navigationController.navigationBar.shadowImage = UIImage();
        self.navigationController.navigationBar.translucent = true;
        self.navigationController.view.backgroundColor = UIColor.clearColor();
        self.navigationController.navigationBar.topItem.title = "Settings";
        self.navigationController.navigationBar.titleTextAttributes = TITLE_TEXT_ATTRIBUTES;
    
        report.keyboardAppearance = UIKeyboardAppearance.Dark
        
        var mainUser = FriendEncapsulator.dequeueFriendEncapsulator(PFUser.currentUser().username)
        mainUser.fetchImage({(image: UIImage)->Void in
            self.backImage.image = image;
        });
        
        self.reportGuide.editable = false
        
        report.layer.borderWidth = 1;
        report.layer.borderColor = UIColor.whiteColor().CGColor;
        //report.layer.cornerRadius = 5
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    func keyboardWillShow(notif: NSNotification) {
        tapBackgroundOutlet.hidden = false
    }

    @IBAction func tapBackground(sender: AnyObject) {
        report.resignFirstResponder()
        tapBackgroundOutlet.hidden = true
    }
    
    @IBAction func submitReport(sender: AnyObject) {
        var reportObj: PFObject = PFObject(className: "Report")
        reportObj["username"] = PFUser.currentUser().username
        reportObj["report"] = report.text
        reportObj.saveEventually()
        var alert = UIAlertController(title: "Thank You!", message: "Your report has been submitted", preferredStyle: UIAlertControllerStyle.Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) in
            var x = self.navigationController.popViewControllerAnimated(true);
        }));
        self.presentViewController(alert, animated: true, completion: nil)
        report.text = ""
    }
    
    @IBAction func backPress(sender: UIButton) {
        self.navigationController.popViewControllerAnimated(true);
    }
}

