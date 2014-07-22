// Playground - noun: a place where people can play

import UIKit



class Small {
    var tiny: Int;
    init() {
        tiny = 5;
    }
    func runPrgm(prgm: (()->Void)->Void) {
        prgm({()->Void in
            self.tiny = 7
            });
    }
}
var a = Small();
a.runPrgm({(pr: ()->Void)->Void in 5;
                                    pr()});
a.tiny;
a.tiny = 6;
/*
func anotherPrgm() {
    var a = Small();
    runPrgm({()->Void in
        a.tiny = 6;
        
        });
    
    a.tiny;
}
anotherPrgm();*/







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
wordNumberer(98682091809184604);

*/







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
