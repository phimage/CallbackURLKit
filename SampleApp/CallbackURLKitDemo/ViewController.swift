//
//  ViewController.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import CallbackURLKit

#if os(iOS)
    import UIKit
    class ViewController: UIViewController {}
#elseif os(OSX)
    import Cocoa
    class ViewController: NSViewController {}
#endif

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openChrome(_ sender: AnyObject!) {
        let chrome = GoogleChrome()
        do {
            try chrome.open(url: "http://www.google.com")
        } catch CallbackURLKitError.appWithSchemeNotInstalled(let scheme) {
            print("chrome(\(scheme)) not installed or not implement x-callback-url in current os")
            
        } catch CallbackURLKitError.callbackURLSchemeNotDefined {
            print("current app scheme not defined")
        } catch let e {
            print("exception \(e)")
        }
    }
    
    @IBAction func printAction(_ sender: AnyObject!) {
        do {
            try CallbackURLKitDemo.instance.printMessage(
                "a message  %20 %  = &toto=a",
                onSuccess:  { parameters in
                    print("parameters \(parameters)")
                },
                onFailure: { error in
                    print("\(error)")
                }
            )
        } catch CallbackURLKitError.appWithSchemeNotInstalled(let scheme) {
            print("\(scheme) not installed or not implement x-callback-url in current os")
            
        } catch CallbackURLKitError.callbackURLSchemeNotDefined {
            print("current app scheme not defined")
        } catch let e {
            print("exception \(e)")
        }
    }

}

