//
//  ViewController.swift
//  CallbackURLKitDemoOSX
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Cocoa
import CallbackURLKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
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

