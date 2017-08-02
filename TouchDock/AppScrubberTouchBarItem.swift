//
//  AppScrubberTouchBarItem.swift
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

let scrubberApplicationsItemReuseIdentifier = "ScrubberApplicationsItemReuseIdentifier"

@available(OSX 10.12.2, *)
class AppScrubberTouchBarItem: NSCustomTouchBarItem, NSScrubberDelegate, NSScrubberDataSource {
    
    var scrubber: NSScrubber!
    
    var runningApplications: [NSRunningApplication] = []
    
    override init(identifier: NSTouchBarItemIdentifier) {
        super.init(identifier: identifier)
        
        scrubber = NSScrubber().then {
            $0.delegate = self
            $0.dataSource = self
            $0.mode = .fixed
            let layout = NSScrubberFlowLayout().then {
                $0.itemSize = NSSize(width: 65, height: 30)
            }
            $0.scrubberLayout = layout
            $0.selectionBackgroundStyle = .roundedBackground
        }
        view = scrubber
        
        scrubber.register(NSScrubberImageItemView.self, forItemIdentifier: "scrubberApplicationsItemReuseIdentifier")
        
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: .NSWorkspaceDidLaunchApplication, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: .NSWorkspaceDidTerminateApplication, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activeApplicationChanged), name: .NSWorkspaceDidActivateApplication, object: nil)
        
        updateRunningApplication(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activeApplicationChanged(n: Notification) {
        updateRunningApplication(animated: true)
    }
    
    func updateRunningApplication(animated: Bool) {
        let newApplications = launchedApplications()
        if animated {
            scrubber.performSequentialBatchUpdates {
                for (index, app) in newApplications.enumerated() {
                    while runningApplications[safe:index].map(newApplications.contains) == false {
                        scrubber.removeItems(at: [index])
                        runningApplications.remove(at: index)
                    }
                    if let oldIndex = runningApplications.index(of: app) {
                        guard oldIndex != index else {
                            return
                        }
                        scrubber.moveItem(at: oldIndex, to: index)
                        runningApplications.move(at: oldIndex, to: index)
                    } else {
                        scrubber.insertItems(at: [index])
                        runningApplications.insert(app, at: index)
                    }
                }
                assert(runningApplications == newApplications)
            }
        } else {
            runningApplications = newApplications
            scrubber.reloadData()
        }
        scrubber.selectedIndex = 0
    }
    
    // MARK: - NSScrubberDataSource
    
    public func numberOfItems(for scrubber: NSScrubber) -> Int {
        return runningApplications.count
    }
    
    public func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let item = scrubber.makeItem(withIdentifier: scrubberApplicationsItemReuseIdentifier, owner: self) as? NSScrubberImageItemView ?? NSScrubberImageItemView()
        item.imageView.imageScaling = .scaleProportionallyDown
        if let icon = runningApplications[index].icon {
            item.image = icon
        }
        return item
    }
    
    public func didFinishInteracting(with scrubber: NSScrubber) {
        guard scrubber.selectedIndex > 0 else {
            return
        }
        runningApplications[scrubber.selectedIndex].activate(options: .activateIgnoringOtherApps)
    }
    
}

extension RangeReplaceableCollection {
    
    mutating func move(at oldIndex: Self.Index, to newIndex: Self.Index) {
        guard oldIndex != newIndex else {
            return
        }
        let item = remove(at: oldIndex)
        insert(item, at: newIndex)
    }
}

extension Collection {
    
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        guard index < endIndex else {
            return nil
        }
        return self[index]
    }
}

// MARK: - Applications

private func launchedApplications() -> [NSRunningApplication] {
    let asns = _LSCopyApplicationArrayInFrontToBackOrder(~0)?.takeRetainedValue()
    return (0..<CFArrayGetCount(asns)).flatMap { index in
        let asn = CFArrayGetValueAtIndex(asns, index)
        guard let pid = pidFromASN(asn)?.takeRetainedValue() else { return nil }
        return NSRunningApplication(processIdentifier: pid as pid_t)
    }
}

private func dockPersistentApplications() -> [NSRunningApplication] {
    let apps = NSWorkspace.shared().runningApplications.filter {
        $0.activationPolicy == .regular
    }
    
    guard let dockDefaults = UserDefaults(suiteName: "com.apple.dock"),
        let persistentApps = dockDefaults.array(forKey: "persistent-apps") as [AnyObject]?,
        let bundleIDs = persistentApps.flatMap({ $0.value(forKeyPath: "tile-data.bundle-identifier") }) as? [String] else {
            return apps
    }
    
    return apps.sorted { (lhs, rhs) in
        if lhs.bundleIdentifier == "com.apple.finder" {
            return true
        }
        switch ((bundleIDs.index(of: lhs.bundleIdentifier!)), bundleIDs.index(of: rhs.bundleIdentifier!)) {
        case (nil, _):
            return false;
        case (_?, nil):
            return true
        case let (i1?, i2?):
            return i1 < i2;
        }
    }
}
