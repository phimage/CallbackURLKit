//
//  ViewController.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import UIKit
import CallbackURLKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openChrome(sender: AnyObject!) {
        let chrome = GoogleChrome()
        do {
            try chrome.openURL("http://www.google.com")
        } catch CallbackURLKitError.AppWithSchemeNotInstalled {
            print("chrome not installed or not implement x-callback-url in current os")
            
        } catch CallbackURLKitError.CallbackURLSchemeNotDefined {
            print("current app scheme not defined")
        } catch let e {
            print("exception \(e)")
        }
    }

}

