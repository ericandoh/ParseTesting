//
//  ShopLook.swift
//  ParseStarterProject
//
//  Created by Eric Oh on 7/28/14.
//
//

import UIKit

//test

class ShopLook {
    var title: String;
    var urlLink: String;
    init(title: String, urlLink: String) {
        self.title = title;
        self.urlLink = urlLink;
    }
    func toDictionary()->[String: String] {
        var dictionary: [String: String] = [:];
        dictionary["title"] = title;
        dictionary["urlLink"] = urlLink;
        return dictionary;
    }
    class func fromDictionary(obj: AnyObject)->ShopLook {
        var dictionary = obj as [String:String];
        return ShopLook(title: dictionary["title"]!, urlLink: dictionary["urlLink"]!);
    }
}
