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
        statusItem.button?.image = #imageLiteral(resourceName: "StatusBarIcon")
        statusItem.length = 32
        statusItem.target = self
        statusItem.action = #selector(clickStatusItem)
        
        if #available(OSX 10.12.2, *) {
            TouchBarController.shared.setupControlStripPresence()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func clickStatusItem() {
        if #available(OSX 10.12.2, *) {
            TouchBarController.shared.updateControlStripPresence()
        }
        statusItem.popUpMenu(statusMenu)
    }
    
}

