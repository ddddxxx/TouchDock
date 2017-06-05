//
//  AppScrubberViewController.swift
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
class AppScrubberViewController: NSViewController, NSScrubberDelegate, NSScrubberDataSource {
    
    @IBOutlet var scrubber: NSScrubber!
    
    var runningApplications: [NSRunningApplication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrubber.selectionBackgroundStyle = .roundedBackground
        
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(updateRunningApplication), name: .NSWorkspaceDidTerminateApplication, object: nil)
        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(updateRunningApplication), name: .NSWorkspaceDidActivateApplication, object: nil)
        
        updateRunningApplication()
    }
    
    func updateRunningApplication() {
        runningApplications = launchedApplications()
        scrubber.reloadData()
        scrubber.selectedIndex = 0
    }
    
    // MARK: - NSScrubberDataSource
    
    public func numberOfItems(for scrubber: NSScrubber) -> Int {
        return runningApplications.count
    }
    
    public func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let view = NSScrubberImageItemView()
        if let icon = runningApplications[index].icon {
            view.image = icon
            view.imageView.imageScaling  = .scaleProportionallyDown
        }
        return view
    }
    
    public func didFinishInteracting(with scrubber: NSScrubber) {
        guard scrubber.selectedIndex > 0 else {
            return
        }
        runningApplications[scrubber.selectedIndex].activate(options: .activateIgnoringOtherApps)
    }
    
}

private func launchedApplications() -> [NSRunningApplication] {
    let asns = _LSCopyApplicationArrayInFrontToBackOrder(~0)?.takeRetainedValue()
    return (0..<CFArrayGetCount(asns)).flatMap { index in
        let asn = CFArrayGetValueAtIndex(asns, index)
        guard let pid = pidFromASN(asn)?.takeRetainedValue() else { return nil }
        return NSRunningApplication(processIdentifier: pid as pid_t)
    }
}
