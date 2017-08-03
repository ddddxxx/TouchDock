//
//  TouchBarController.swift
//
//  This file is part of TouchDock
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa

@available(OSX 10.12.2, *)
class TouchBarController: NSObject, NSTouchBarDelegate {
    
    static let shared = TouchBarController()
    
    let touchBar = NSTouchBar()
    weak var appScrubber: AppScrubberTouchBarItem?
    
    private override init() {
        super.init()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.appScrubber]
        
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { event in
            if event.modifierFlags.contains(.command) {
                self.presentTouchBar()
            } else {
                self.dismissTouchBar()
            }
        }
    }
    
    func setupControlStripPresence() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let item = NSCustomTouchBarItem(identifier: .systemTrayItem)
        item.view = NSButton(image: #imageLiteral(resourceName: "TouchBarIcon"), target: self, action: #selector(presentTouchBar))
        NSTouchBarItem.addSystemTrayItem(item)
        DFRElementSetControlStripPresenceForIdentifier(.systemTrayItem, true)
    }
    
    func updateControlStripPresence() {
        DFRElementSetControlStripPresenceForIdentifier(.systemTrayItem, true)
    }
    
    @objc
    private func presentTouchBar() {
        appScrubber?.updateRunningApplication(animated: false)
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: .systemTrayItem)
    }
    
    private func dismissTouchBar() {
        NSTouchBar.minimizeSystemModalFunctionBar(touchBar)
    }
    
    // MARK: - NSTouchBarDelegate
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.appScrubber:
            appScrubber = AppScrubberTouchBarItem(identifier: identifier)
            return appScrubber
        default:
            return nil
        }
    }
    
}

extension NSTouchBarItemIdentifier {
    static let appScrubber = NSTouchBarItemIdentifier("ddddxxx.TouchDock.touchBar.appScrubber")
    static let systemTrayItem = NSTouchBarItemIdentifier("ddddxxx.TouchDock.touchBar.systemTrayItem")
}
