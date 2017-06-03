//
//  AppDelegate.swift
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if #available(OSX 10.12.2, *) {
            TouchBarController.shared.setupTouchBar()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

