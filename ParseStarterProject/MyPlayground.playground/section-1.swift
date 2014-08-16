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

/*
["QWERTY","AWESOME","ASAWESOMEASME"]

var lst: [Int] = [];

var x = 6
sqrt(Float(x))

for i in 0..<200 {
    var r = random() % 100000000
    lst.append(Int(sqrt(sqrt(Float(r)))));
}
var y: Int;
//lst.sort({$0 > $1});
for i in 0..<200 {
    y = lst[i];
}

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

scrambler(0, 100000, 5);
var counter: Int = 0;

for index in 1...999 {
    if ((index % 3 == 0) || (index % 5 == 0)) {
        counter += index
    }
}

counter*/

var text = "HI";

var error: NSError?;

var pattern = "(#.+?(?=\\b|\\n))|(@.+?(?=\\b|\\n))|((.|\\n)+?(?=#|@|$))";
var regex: NSRegularExpression = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.fromMask(0), error: &error);

var matches = regex.matchesInString(text, options: NSMatchingOptions.fromRaw(0)!, range: NSRange(location: 0, length: countElements(text))) as [NSTextCheckingResult];

var lstOfStrings: Array<String> = [];

for match in matches {
    var attributedStringPiece: NSAttributedString;
    //var piece = aString.substringWithRange();
    var individualString: String = ((text as NSString).substringFromIndex(match.range.location) as NSString).substringToIndex(match.range.length);
    lstOfStrings.append(individualString);
}
lstOfStrings




