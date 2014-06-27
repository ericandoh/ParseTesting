//
//  ImagePost.swift
//  ParseStarterProject
//
//  Sample subclassing of PFObject. Do NOT use this to store ImagePost!
//  (we will just work with normal PFObjects and handle in serverinteractor)
//
//  Created by Eric Oh on 6/26/14.
//
//

import UIKit

class ImagePost: PFObject {
    class func parseClassName() -> String! {
        return "ImagePost"
    }
}
