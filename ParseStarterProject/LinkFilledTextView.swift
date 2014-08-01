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

let TYPE_TAG = "EXTERNAL_VIEW_LINK";

enum ExternalViewLink: String {
    case DEFAULT = "Default";
    case USER = "User";
    case TAG = "Tag";
}


class LinkFilledTextView: UITextView {
    
    var owner: UIViewController;
    var canRespond: Bool = false;
    
    init(frame: CGRect, textContainer: NSTextContainer!, owner: UIViewController) {
        self.owner = owner;
        super.init(frame: frame, textContainer: textContainer);
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"));
        self.userInteractionEnabled = false;
        //self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.fromRaw(0)!, context: nil);
    }
    override func awakeFromNib() {
        super.awakeFromNib();
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"));
        self.userInteractionEnabled = false;
        //self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.fromRaw(0)!, context: nil);
    }
    /*init(frame: CGRect) {
    super.init(frame: frame);
    // Initialization code
    //self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getPressedWordWithRecognizer:"))
    }*/
    func getPressedWordWithRecognizer(recognizer: UIGestureRecognizer) {
        
        var textView = recognizer.view as UITextView;
        var layoutManager = textView.layoutManager;
        var point: CGPoint = recognizer.locationInView(textView);
        
        point.x -= textView.textContainerInset.left;
        point.y -= textView.textContainerInset.top;
        
        var characterIndex = layoutManager.characterIndexForPoint(point, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil);
        
        if (characterIndex < textView.textStorage.length) {
            var range = NSRangePointer.alloc(2);
            var value: AnyObject! = textView.attributedText.attribute(TYPE_TAG, atIndex: characterIndex, effectiveRange: range);
            //NSLog((value as String)+" was clicked");
            //NSLog("\(range.memory.length) for \(range.memory.location)");
            var realText = text.substringFromIndex(range.memory.location).substringToIndex(range.memory.length);
            //NSLog(realText);
            var typeOfString = ExternalViewLink.fromRaw(value as String)!;
            if (typeOfString == ExternalViewLink.TAG) {
                var searchTerm = realText.substringFromIndex(1);
                
                var nextBoard : UIViewController = self.owner.storyboard.instantiateViewControllerWithIdentifier("SearchWindow") as UIViewController;
                (nextBoard as SearchViewController).currentTerm = searchTerm;
                self.owner.navigationController.pushViewController(nextBoard, animated: true);
            }
            else if (typeOfString == ExternalViewLink.USER) {
                var friendName = realText.substringFromIndex(1);
                var friend = FriendEncapsulator(friendName: friendName);
                friend.exists({(exist: Bool) in
                    if (exist) {
                        var nextBoard : UIViewController = self.owner.storyboard.instantiateViewControllerWithIdentifier("UserProfilePage") as UIViewController;
                        (nextBoard as UserProfileViewController).receiveUserInfo(friend);
                        self.owner.navigationController.pushViewController(nextBoard, animated: true);
                    }
                    });
            }
        }
        
        /*
        
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
        }*/
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
    // Drawing code
    }
    */
    func setTextAfterAttributing(text: String) {
        self.attributedText = self.convertToAttributed(text);
    }
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>) {
        var txtView = object as UITextView;
        var topoffset = (txtView.bounds.size.height - txtView.contentSize.height * txtView.zoomScale)/2.0;
        topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
        txtView.contentOffset = CGPoint(x: 0, y: -topoffset);
    }
    override func canBecomeFirstResponder() -> Bool  {
        return canRespond;
    }
    //function that takes in a string of regular text that is embedded with tags/author links
    //and converts to an attributed text.
    func convertToAttributed(text: String)->NSAttributedString {

        var attributedString = NSMutableAttributedString();
        
        var error: NSError?;
        
        var pattern = "(#.+?\\b)|(@.+?\\b)|(.+?(?=#|@|$))";
        var regex: NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.fromMask(0), error: &error);
        
        var matches = regex.matchesInString(text, options: NSMatchingOptions.fromRaw(0)!, range: NSRange(location: 0, length: countElements(text))) as [NSTextCheckingResult];
        
        
        var attributedStringPiece: NSAttributedString;
        for match in matches {
            //var piece = aString.substringWithRange();
            var individualString: String = text.substringFromIndex(match.range.location).substringToIndex(match.range.length);
            if (individualString.hasPrefix("#")) {
                let font = UIFont(name: "Futura-CondensedExtraBold", size:14.0);
                let attrDict = [TYPE_TAG: ExternalViewLink.TAG.toRaw(), NSFontAttributeName: font];
                attributedStringPiece = NSAttributedString(string: individualString, attributes: attrDict);
                canRespond = true;
                self.userInteractionEnabled = true;
            }
            else if (individualString.hasPrefix("@")) {
                let font = UIFont(name: "Futura-CondensedExtraBold", size:14.0);
                let attrDict = [TYPE_TAG: ExternalViewLink.USER.toRaw(), NSFontAttributeName: font];
                attributedStringPiece = NSAttributedString(string: individualString, attributes: attrDict);
                canRespond = true;
                self.userInteractionEnabled = true;
            }
            else {
                let font = UIFont(name: "Futura", size:14.0);
                let attrDict = [TYPE_TAG: ExternalViewLink.DEFAULT.toRaw(), NSFontAttributeName: font];
                attributedStringPiece = NSAttributedString(string: individualString, attributes: attrDict);
            }
            attributedString.appendAttributedString(attributedStringPiece);
        }
        
        return attributedString;
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
