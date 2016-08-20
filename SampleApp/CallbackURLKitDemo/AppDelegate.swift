//
//  AppDelegate.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import CallbackURLKit

#if os(iOS)
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let manager = Manager.sharedInstance
        manager.callbackURLScheme = Manager.URLSchemes?.first
        manager[CallbackURLKitDemo.PrintActionString] = CallbackURLKitDemo.PrintAction
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        Manager.sharedInstance.handleOpenURL(url)
        return true
    }

}
    
#elseif os(OSX)
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let manager = Manager.sharedInstance
        manager.registerToURLEvent()
        manager.callbackURLScheme = Manager.URLSchemes?.first
        manager[CallbackURLKitDemo.PrintActionString] = CallbackURLKitDemo.PrintAction
    }
    
}

#endif
