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

class AppScrubberTouchBarItem: NSCustomTouchBarItem, NSScrubberDelegate, NSScrubberDataSource {
    
    var scrubber: NSScrubber!
    
    var runningApplications: [NSRunningApplication] = []
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        scrubber = NSScrubber().then {
            $0.delegate = self
            $0.dataSource = self
            $0.mode = defaults.appScrubberMode
            let layout = NSScrubberFlowLayout().then {
                $0.itemSize = NSSize(width: 65, height: 30)
            }
            $0.scrubberLayout = layout
            $0.selectionBackgroundStyle = .roundedBackground
        }
        view = scrubber
        
        scrubber.register(NSScrubberImageItemView.self, forItemIdentifier: .scrubberApplicationsItem)
        
        workspaceNC.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        workspaceNC.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        workspaceNC.addObserver(self, selector: #selector(activeApplicationChanged), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        defaults.addObserver(self, forKeyPath: appScrubberOrderIndex, context: nil)
        
        updateRunningApplication(animated: false)
    }
    
    @objc func activeApplicationChanged(n: Notification) {
        updateRunningApplication(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateRunningApplication(animated: false)
    }
    
    func updateRunningApplication(animated: Bool) {
        let isDockOrder = defaults.integer(forKey: appScrubberOrderIndex) != 0
        let newApplications = (isDockOrder ? dockPersistentApplications() : launchedApplications()).filter {
            !$0.isTerminated && $0.bundleIdentifier != nil
        }
        if animated {
            scrubber.performSequentialBatchUpdates {
                log("-----update-----")
                for (index, app) in newApplications.enumerated() {
                    while runningApplications[safe:index].map(newApplications.contains) == false {
                        scrubber.removeItems(at: [index])
                        let r = runningApplications.remove(at: index)
                        log("remove \(r.localizedName!) at \(index)")
                    }
                    if let oldIndex = runningApplications.index(of: app) {
                        guard oldIndex != index else {
                            return
                        }
                        scrubber.moveItem(at: oldIndex, to: index)
                        runningApplications.move(at: oldIndex, to: index)
                        log("move \(app.localizedName!) at \(oldIndex) to \(index)")
                    } else {
                        scrubber.insertItems(at: [index])
                        runningApplications.insert(app, at: index)
                        log("insert \(app.localizedName!) to \(index)")
                    }
                }
                assert(runningApplications == newApplications)
            }
        } else {
            runningApplications = newApplications
            scrubber.reloadData()
            scrubber.animator().selectedIndex = -1
        }
        let index = NSWorkspace.shared.frontmostApplication.flatMap(newApplications.index) ?? -1
        scrubber.selectedIndex = index
    }
    
    // MARK: - NSScrubberDataSource
    
    public func numberOfItems(for scrubber: NSScrubber) -> Int {
        return runningApplications.count
    }
    
    public func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let item = scrubber.makeItem(withIdentifier: .scrubberApplicationsItem, owner: self) as? NSScrubberImageItemView ?? NSScrubberImageItemView()
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
        let app = runningApplications[scrubber.selectedIndex]
        app.reopen()
        app.activate(options: .activateIgnoringOtherApps)
    }
    
}

extension NSRunningApplication {
    
    func sendEvent(eventID: AEEventID) {
        let target = NSAppleEventDescriptor(processIdentifier: processIdentifier)
        let event = NSAppleEventDescriptor(eventClass: kCoreEventClass,
                                           eventID: kAEReopenApplication,
                                           targetDescriptor: target,
                                           returnID: AEReturnID(kAutoGenerateReturnID),
                                           transactionID: AETransactionID(kAnyTransactionID))
        AESendMessage(event.aeDesc, nil, AESendMode(kAENoReply), kAEDefaultTimeout)
    }
    
    func reopen() {
        sendEvent(eventID: kAEReopenApplication)
    }
}

// MARK: - Applications

private func launchedApplications() -> [NSRunningApplication] {
    let asns = _LSCopyApplicationArrayInFrontToBackOrder(~0)
    return NSRunningApplication._transformASNArrayToAppArray(withRelease: asns?.takeUnretainedValue())
}

private func dockPersistentApplications() -> [NSRunningApplication] {
    let apps = NSWorkspace.shared.runningApplications.filter {
        $0.activationPolicy == .regular
    }
    
    guard let dockDefaults = UserDefaults(suiteName: "com.apple.dock"),
        let persistentApps = dockDefaults.array(forKey: "persistent-apps") as [AnyObject]?,
        let bundleIDs = persistentApps.compactMap({ $0.value(forKeyPath: "tile-data.bundle-identifier") }) as? [String] else {
            return apps
    }
    
    return apps.sorted { (lhs, rhs) in
        if lhs.bundleIdentifier == "com.apple.finder" {
            return true
        }
        if rhs.bundleIdentifier == "com.apple.finder" {
            return false
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
