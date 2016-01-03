//
//  AppDelegate.swift
//  CallbackURLKitDemoOSX
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Cocoa
import CallbackURLKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
       NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector:"handleGetURLEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        let manager = Manager.sharedInstance
        manager.callbackURLScheme = Manager.URLSchemes?.first
        
        manager["print"] = { parameters, success, failed, cancel in
            if let text = parameters["text"] {
                print(text)
                success(nil)
            } else {
                failed(DemoErrorType.NoText)
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue, url = NSURL(string: urlString) {
            Manager.sharedInstance.handleOpenURL(url)
        }
    }
}

