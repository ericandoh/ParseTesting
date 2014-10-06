//
//  CompatibleAlertViews.swift
//  FashionStash
//
//  Class that calls and makes UIAlerts that are compatible for both IOS8 and IOS7.1
//  I should be ashamed of myself for using _name1 _name2 instead of _name0 _name1
//  Please forgive me
//
//  Created by Eric Oh on 8/19/14.
//
//

import UIKit

class CompatibleAlertViews: NSObject, UIAlertViewDelegate {
    
    var presenter: UIViewController;
    var myAction1: (()->Void)? = nil;
    var myAction2: ((String)->Void)? = nil;
    var myAction3: ((String, String)->Void)? = nil;
    
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
            var alert = UIAlertView();
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
    func makeNoticeWithActionAndField(title: String, message: String, actionName: String, actionHolder: String, buttonAction: (String)->Void) {
        self.makeNoticeWithActionAndField(title, message: message, actionName: actionName, actionHolder: actionHolder, secure: false, buttonAction: buttonAction);
    }
    func makeNoticeWithActionAndField(title: String, message: String, actionName: String, actionHolder: String, secure: Bool, buttonAction: (String)->Void) {
        if (iOS8) {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
                field.placeholder = actionHolder;
            });
            (alert.textFields![0] as UITextField).secureTextEntry = secure;
            alert.addAction(UIAlertAction(title: actionName, style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                buttonAction((alert.textFields![0] as UITextField).text);
                return;
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
            presenter.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.myAction2 = buttonAction;
            var alert = UIAlertView();
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
            alert.delegate = self;
            alert.message = message;
            alert.addButtonWithTitle(actionName);
            alert.addButtonWithTitle("Cancel");
            alert.title = title;
            alert.textFieldAtIndex(0)!.placeholder = actionHolder;
            alert.show();
            
        }
    }
    
    func makeNoticeWithActionAndFieldAndField(title: String, message: String, actionName: String, actionHolder1: String, actionHolder2: String, buttonAction: (String, String)->Void) {
        self.makeNoticeWithActionAndFieldAndField(title, message: message, actionName: actionName, actionHolder1: actionHolder1, actionHolder2: actionHolder2, actionString1: "", actionString2: "", buttonAction: buttonAction);
    }
    func makeNoticeWithActionAndFieldAndField(title: String, message: String, actionName: String, actionHolder1: String, actionHolder2: String, actionString1: String, actionString2: String, buttonAction: (String, String)->Void) {
        self.makeNoticeWithActionAndFieldAndField(title, message: message, actionName: actionName, actionHolder1: actionHolder1, actionHolder2: actionHolder2, actionString1: actionString1, actionString2: actionString2, secure1: false, secure2: false, buttonAction: buttonAction);
    }
    func makeNoticeWithActionAndFieldAndField(title: String, message: String, actionName: String, actionHolder1: String, actionHolder2: String, actionString1: String, actionString2: String, secure1: Bool, secure2: Bool, buttonAction: (String, String)->Void) {
        if (iOS8) {
            let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
            alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
                field.placeholder = actionHolder1;
            });
            alert.addTextFieldWithConfigurationHandler({(field: UITextField!) in
                field.placeholder = actionHolder2;
            });
            (alert.textFields![0] as UITextField).text = actionString1;
            (alert.textFields![1] as UITextField).text = actionString2;
            (alert.textFields![0] as UITextField).secureTextEntry = secure1;
            (alert.textFields![1] as UITextField).secureTextEntry = secure2;
            alert.addAction(UIAlertAction(title: actionName, style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                buttonAction((alert.textFields![0] as UITextField).text, (alert.textFields![1] as UITextField).text);
                return;
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil));
            presenter.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.myAction3 = buttonAction;
            var alert = UIAlertView();
            alert.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput;
            alert.delegate = self;
            alert.message = message;
            alert.addButtonWithTitle(actionName);
            alert.addButtonWithTitle("Cancel");
            alert.title = title;
            alert.textFieldAtIndex(0)!.placeholder = actionHolder1;
            alert.textFieldAtIndex(1)!.placeholder = actionHolder2;
            alert.textFieldAtIndex(1)!.secureTextEntry = false;
            alert.show();
            
        }
    }
    
    
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: NSInteger) {
        switch buttonIndex {
        case 0:
            if (self.myAction1 != nil) {
                self.myAction1!();
            }
            else if (self.myAction2 != nil) {
                self.myAction2!(alertView.textFieldAtIndex(0)!.text);
            }
            else if (self.myAction3 != nil) {
                self.myAction3!(alertView.textFieldAtIndex(0)!.text, alertView.textFieldAtIndex(1)!.text)
            }
        default:
            var x = 5;
        }
    }
    /*func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
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
    func clickAt(index: Int) {
        NSLog("C")
    }*/
}
