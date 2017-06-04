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
    
    @IBOutlet weak var statusMenu: NSMenu!
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.menu = statusMenu
        statusItem.button?.image = #imageLiteral(resourceName: "AppStore_16x")
        statusItem.length = 30
        
        if #available(OSX 10.12.2, *) {
            TouchBarController.shared.setupControlStripPresence()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

