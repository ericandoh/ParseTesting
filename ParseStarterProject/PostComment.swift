//
//  PostComment.swift
//  ParseStarterProject
//
//  A comment in reply to a post. 
//  Can be served right now with just a string, if we add likes we can scale it via this class
//  Post comments will be stored (for now) as Strings in a list, if we add likes for comments we might want to rewrite the backend
//
//  Created by Eric Oh on 7/7/14.
//
//

class PostComment: NSObject {
    var commentString: String;
    init(content: String) {
        commentString = content;
    }
}
