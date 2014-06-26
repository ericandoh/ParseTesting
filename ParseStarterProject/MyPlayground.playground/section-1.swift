// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
"hello world"

println("why")

var num = 3+5
while(false) {
    num = num + 1
    println(random())
}
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
}
