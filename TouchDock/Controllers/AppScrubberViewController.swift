//
//  AppScrubberViewController.swift
//  TouchDock
//
//  Created by 邓翔 on 2017/6/3.
//  Copyright © 2017年 ddddxxx. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class AppScrubberViewController: NSViewController, NSScrubberDelegate, NSScrubberDataSource {
    
    @IBOutlet var scrubber: NSScrubber!
    
    var runningApplications: [NSRunningApplication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        runningApplications = NSWorkspace.shared().runningApplications.filter {
            $0.activationPolicy == .regular
        }
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
    
}
