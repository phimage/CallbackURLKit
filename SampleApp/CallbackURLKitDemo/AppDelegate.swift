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
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let manager = Manager.shared
        manager.callbackURLScheme = Manager.urlSchemes?.first
        manager[CallbackURLKitDemo.PrintActionString] = CallbackURLKitDemo.PrintAction

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return Manager.shared.handleOpen(url: url)
    }

}

#elseif os(OSX)
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let manager = Manager.shared
        manager.registerToURLEvent()
        manager.callbackURLScheme = Manager.urlSchemes?.first
        manager[CallbackURLKitDemo.PrintActionString] = CallbackURLKitDemo.PrintAction

        manager["success"] = { (_, success, _, _) in
            DispatchQueue.main.async {
                success(nil)
            }
        }

    }

}

#endif
