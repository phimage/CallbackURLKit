//
//  AppDelegate.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import UIKit
import CallbackURLKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
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
        
        return true
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        Manager.sharedInstance.handleOpenURL(url)
        return true
    }


}

