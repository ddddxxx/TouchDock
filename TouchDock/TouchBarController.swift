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
        touchBar.defaultItemIdentifiers = [.appScrubber]
    }
    
    func setupTouchBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let item = NSCustomTouchBarItem(identifier: .systemTrayItem)
        item.view = NSButton(image: #imageLiteral(resourceName: "AppStore"), target: self, action: #selector(expand))
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(.systemTrayItem, true)
    }
    
    func expand() {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
    }
    
    // MARK: - NSTouchBarDelegate
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.appScrubber:
            let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
            touchBarItem.viewController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AppScrubberViewController") as! AppScrubberViewController)
            return touchBarItem
        default:
            return nil
        }
    }
    
}

extension NSTouchBarItemIdentifier {
    static let appScrubber = NSTouchBarItemIdentifier("ddddxxx.TouchDock.touchBar.appScrubber")
    static let systemTrayItem = NSTouchBarItemIdentifier("ddddxxx.TouchDock.touchBar.systemTrayItem")
}
