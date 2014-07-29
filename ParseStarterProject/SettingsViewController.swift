//
//  SettingsViewController.swift
//  ParseStarterProject
//
//  Created by temp on 7/25/14.
//
//

import Foundation

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBAction func logOffAction(sender: UIButton) {
        if (!ServerInteractor.isAnonLogged()) {
            ServerInteractor.logOutUser();
        }
    }
}