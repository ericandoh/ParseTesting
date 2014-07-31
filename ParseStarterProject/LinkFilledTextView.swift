//
//  LinkFilledTextView.swift
//  ParseStarterProject
//
//  A text view that, when clicked, triggers a push to the appropriate view controller depending on the text pressed
//  
//  @user => find a user with that name, and opens a userprofileview of that user
//  #tag => opens a search window searching for that tag
//
//  Word gesturizer clicker programmed with help of 
//  http://stackoverflow.com/questions/21749049/perform-action-by-clicking-on-some-word-in-uitextview-or-uilabel
//
//  Nevermind, above link doesn't work. Will be trying with:
//  http://stackoverflow.com/questions/19332283/detecting-taps-on-attributed-text-in-a-uitextview-on-ios-7
//  later
//
//  Created by Eric Oh on 7/31/14.
//
//

import UIKit

import UIKit

class LinkFilledTextView: UITextView {
    var owner: UIViewController;
    init(frame: CGRect, textContainer: NSTextContainer!, owner: UIViewController) {
        self.owner = owner;
        super.init(frame: frame, textContainer: textContainer);
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"));
    }
    override func awakeFromNib() {
        super.awakeFromNib();
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"));
    }
    /*init(frame: CGRect) {
    super.init(frame: frame);
    // Initialization code
    //self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"))
    }*/
    func getPressedWordWithRecognizer(recognizer: UIGestureRecognizer) {
        var textView = recognizer.view as UITextView;
        var point: CGPoint = recognizer.locationInView(textView);
        var tapPosition: UITextPosition = textView.closestPositionToPoint(point);
        var textRange: UITextRange = textView.tokenizer.rangeEnclosingPosition(tapPosition, withGranularity: UITextGranularity.Word, inDirection: UITextDirection.bridgeFromObjectiveC(UITextLayoutDirection.Right.toRaw()));
        var text: String = textView.textInRange(textRange);
        
        NSLog("Text: \(text)");
        
        if (text.hasPrefix("@")) {
            //is a user!
            var friendName = text.substringFromIndex(1);
            var friend = FriendEncapsulator(friendName: friendName);
            friend.exists({(exist: Bool) in
                if (exist) {
                    var nextBoard : UIViewController = self.owner.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                    (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                    self.owner.navigationController.pushViewController(nextBoard, animated: true);
                }
                });
        }
        else if (text.hasPrefix("#") && countElements(text) > 1) {
            //is a search!
            var searchTerm = text.substringFromIndex(1);
            var nextBoard : UIViewController = self.owner.storyboard.instantiateViewControllerWithIdentifier("SearchWindow") as UIViewController;
            self.owner.navigationController.pushViewController(nextBoard, animated: true);
            (nextBoard as SearchViewController).startSearch(searchTerm);
        }
        else {
            var searchTerm = text.substringFromIndex(0);
            var nextBoard : UIViewController = self.owner.storyboard.instantiateViewControllerWithIdentifier("SearchWindow") as UIViewController;
            (nextBoard as SearchViewController).currentTerm = searchTerm;
            self.owner.navigationController.pushViewController(nextBoard, animated: true);
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
    // Drawing code
    }
    */
    class func convertToAttributed(text: String) {
        /*
        NSFont *font = [NSFont fontWithName:@"Palatino-Roman" size:14.0];
        NSDictionary *attrsDictionary =
        [NSDictionary dictionaryWithObject:font
        forKey:NSFontAttributeName];
        NSForegroundColorAttributeName
        //add key-value to dictionary, i.e. "our_text_type": "USER/TAG/DEFAULT"
        NSAttributedString *attrString =
        [[NSAttributedString alloc] initWithString:@"strigil"
        attributes:attrsDictionary];
        
        string beginEditting
        string addAttribute
        
        use NSMutableAttributedString
        setAttributes:range
        addAttribute:value:range
        addAttributes:range
        
        ..
        appendAttributedString
        insertAttributedString;atIndex
        replaceCharactersInRange:withAttributedString
        setAttributedString
        
        to fetch
        attributesAtIndex:effectiveRange
        attributedSubstringFromRange
        
        */
    }
}
