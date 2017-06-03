//
//  TouchBarController.swift
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class TouchBarController: NSObject, NSTouchBarDelegate {
    
    static let shared = TouchBarController()
    
    var touchBar = NSTouchBar()
    
    private override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = []
    }
    
    func setupTouchBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let item = NSCustomTouchBarItem(identifier: .systemTrayItem)
        item.view = NSButton(title: "TouchDock", target: self, action: #selector(expand))
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(.systemTrayItem, true)
    }
    
    func expand() {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
    }
    
    // MARK: - NSTouchBarDelegate
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        default:
            return nil
        }
    }
    
}

extension NSTouchBarItemIdentifier {
    static let systemTrayItem = NSTouchBarItemIdentifier("ddddxxx.TouchDock.touchBar.systemTrayItem")
}
