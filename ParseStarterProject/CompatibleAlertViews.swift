//
//  CompatibleAlertViews.swift
//  FashionStash
//
//  Class that calls and makes UIAlerts that are compatible for both IOS8 and IOS7.1
//
//  Created by Eric Oh on 8/19/14.
//
//

import UIKit

class CompatibleAlertViews: NSObject, UIAlertViewDelegate {
    
    var presenter: UIViewController;
    var alert: UIAlertView = UIAlertView();
    var myAction1: (()->Void)? = nil;
    
    init(presenter: UIViewController) {
        self.presenter = presenter;
    }
    func makeNoticeWithAction(title: String, message: String, actionName: String, buttonAction: ()->Void) {
        if (iOS8) {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: actionName, style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                buttonAction();
                return;
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
            presenter.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.myAction1 = buttonAction;
            //var alert = UIAlertView();
            alert.delegate = self;
            alert.message = message;
            alert.addButtonWithTitle(actionName);
            alert.addButtonWithTitle("Cancel");
            alert.title = title;
            alert.show();
        }
    }
    //a notice with a simple title and message, and an "OK"
    class func makeNotice(title: String, message: String, presenter: UIViewController) {
        if (iOS8) {
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil));
            presenter.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertView();
            alert.title = title;
            alert.message = message;
            alert.addButtonWithTitle("OK");
            alert.show();
        }
    }
    /*class func makeUnfollowButton(username: String, presenter: UIViewController, targetButton: UIButton) {
        var alerter = CompatibleAlertViews(presenter: presenter);
        alerter.makeNoticeWithAction("Unfollow "+username, message: "Unfollow "+username+"?", actionName: "Unfollow", buttonAction: {
            () in
            ServerInteractor.removeAsFollower(username);
            //update button
            targetButton.setBackgroundImage(FOLLOW_ME_ICON, forState: UIControlState.Normal);
        });
    }*/
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: NSInteger) {
        NSLog("a");
        /*
        switch buttonIndex {
        case 0:
            if (self.myAction1 != nil) {
                self.myAction1!();
            }
        default:
            var x = 5;
        }*/
    }
    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        NSLog("\(buttonIndex)")
    }
    func alertView(alertView: UIAlertView!, willDismissWithButtonIndex buttonIndex: Int) {
        NSLog("B");
    }
    func alertViewCancel(alertView: UIAlertView!) {
        NSLog("C");
    }
    func alertViewShouldEnableFirstOtherButton(alertView: UIAlertView!) -> Bool {
        return false;
    }
}
