// Playground - noun: a place where people can play

import UIKit


var dictic = [String: AnyObject]();

dictic["Hello"] = 6;

func what(some: (Bool, NSError!)->Void) {
    //some(false);
    some(true, nil);
}

what({(fall: Bool, error: NSError!)->Void in
    NSLog("Hello \(fall)");
    fall
    });

class Hello {
    var hi: String = "bro";
}
class Mello: Hello {
    var bro: String = "hi";
}
var a = Mello();

var b: Hello = a as Hello;

(b as Mello).bro

var c: Mello? = a;

if (c) {
    6
}

var field = UITextField();
field.text = "What";

field.text;

var alert = UIAlertController(title: "Yo", message: "YO", preferredStyle: UIAlertControllerStyle.Alert);
