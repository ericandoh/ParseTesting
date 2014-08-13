// Playground - noun: a place where people can play

import UIKit

/*
func wordNumberer(num: Int)->String {
    if (num > 1000000) {
        return "\(num / 1000000)M"
    }
    else if (num > 1000) {
        return "\(num / 1000)K"
    }
    return "\(num)"
}

wordNumberer(13);
wordNumberer(723);
wordNumberer(4216);
wordNumberer(10484);
wordNumberer(10999);
wordNumberer(409298);
wordNumberer(50194809);
wordNumberer(98682091809184604);*/

var num = random() % 100;

for i in 0..<0{
    print(i);
}
var currentDate = NSDate();
var oneWeekAgo = currentDate.dateByAddingTimeInterval(-7*24*60*60);

func scrambler(start:Int, end:Int, need: Int)->Array<Int> {
    if (need > end - start) {
        return [];
    }
    var replacementDict: [Int: Int] = [:];
    var rangeToPick = end - start;
    var picked: Array<Int> = [];
    for i in 0..<need {
        var pick = random() % rangeToPick;
        //if (replacementDict[pick + start] != nil) {
            //replacementDict[pick + start] = replacementDict[pick + start]!;
        //}
        //else {
        if (replacementDict[pick + start] != nil) {
            picked.append(replacementDict[pick+start]!);
        }
        else {
            picked.append(pick+start);
        }
        if (replacementDict[rangeToPick + start - 1] != nil) {
            replacementDict[pick + start] = replacementDict[rangeToPick + start - 1];
        }
        else {
            replacementDict[pick + start] = rangeToPick + start - 1;
        }
        //}
        rangeToPick--;
    }
    return picked;
}

var a: Array<String>? = [];

if (a != nil && a!.count == 0) {
    println("hi");
}

scrambler(0, 100000, 5);

let GREEN_HEX = 0x94eed2;

//163,255,198

let SIDE_MENU_BACK_RED = CGFloat((GREEN_HEX & 0xFF0000) >> 16);
let SIDE_MENU_BACK_GREEN = CGFloat((GREEN_HEX & 0xFF00) >> 8);
let SIDE_MENU_BACK_BLUE = CGFloat((GREEN_HEX & 0xFF));

//for i in 0...(-1) {
    //print(i)
//}

/*
var dictionary: [String: String] = [:];
dictionary.keys
var arr = [1,2,3];
contains(arr, 3);
for x in "H" {
    var y: String = String(x)
}*/

//var aString = "hello #omg #lol\n @hi seriously $really\n troll'ed";
//var aString = "ABCD#lol\nC\nD";
var aString = "meepmeep \n John"

var error: NSError?;

//var pattern = "(#.+?\\b)|(@.+?\\b)|(.+?(?=#|@|$))";
var pattern = "(#.+?(?=\\b|\\n))|(@.+?(?=\\b|\\n))|((.|\\n)+?(?=#|@|$))";
var regex: NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.fromMask(0), error: &error);

var matches = regex.matchesInString(aString, options: NSMatchingOptions.fromRaw(0)!, range: NSRange(location: 0, length: countElements(aString))) as [NSTextCheckingResult];

matches.count;
var results: [String] = [];
for match in matches {
    match.range;
    //var piece = aString.substringWithRange();
    results.append(((aString as NSString).substringFromIndex(match.range.location) as NSString).substringToIndex(match.range.length));
}
results;
if (results[results.count - 1].hasPrefix("\n")) {
    5;
}
else if (results[results.count - 1].hasPrefix(" ")) {
    7;
}
else {
    6;
}

/*var str = "hello, tag, sample moment really-hot,ootd,hothot     ohgod"

var array = str.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ", "))
array = array.filter({(obj: String)->Bool in obj != ""});
array


var a=1
a++;
a
*/

/*
var str = "Hello, playground"
"hello world"

println("why")

var num = 3+5
while(false) {
    num = num + 1
    println(random())
}
*/
/*
var numr = 3;
//lets cause stack overflow error for the lels
func recursive(number: Int) -> Int {
    if (number == 300)
        return 0
    number + 1
    return recursive(number + 1)
}

recursive(numr)*/
/*
var head = 1.0
var tail = 2.0
var head2 = 4.0
var tail2 = -4.0
var headPos = 2.0
var tailPos = 2.0

var iterations = 10
while(iterations > 0) {
    iterations--;
    if (headPos > tailPos) {
        head -= 0.25
        tail += 0.25
    }
    else {
        head += 0.25
        tail -= 0.25
    }
    head2 += head
    tail2 += tail
    headPos += head2
    tailPos += tail2
    headPos
    tailPos
}*/

/*
var someArray: Int[] = Int[](count: 3, repeatedValue: 0)
someArray += [1,2,3];
someArray.insert(3, atIndex: 0)
someArray.insert(5, atIndex: 1)
someArray.insert(7, atIndex: 3)
//someArray[3] = 5
//someArray[0] = 4
//someArray[1] = 3
for a in someArray {
    a
}
5+3

var array = [1,2];
array.removeLast();
array.removeLast();
array*/
