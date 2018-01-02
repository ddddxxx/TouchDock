//
//  Constants.swift
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

let defaults = UserDefaults.standard
let workspaceNC = NSWorkspace.shared.notificationCenter

extension NSUserInterfaceItemIdentifier {
    
    static let scrubberApplicationsItem = NSUserInterfaceItemIdentifier("ScrubberApplicationsItemReuseIdentifier")
}

extension NSTouchBarItem.Identifier {
    
    static let appsOrder = NSTouchBarItem.Identifier("ddddxxx.TouchDock.touchBar.appsOrder")
    static let appScrubber = NSTouchBarItem.Identifier("ddddxxx.TouchDock.touchBar.appScrubber")
    
    static let systemTrayItem = NSTouchBarItem.Identifier("ddddxxx.TouchDock.touchBar.systemTrayItem")
}

let appScrubberOrderDock = "AppScrubberOrderDock"
