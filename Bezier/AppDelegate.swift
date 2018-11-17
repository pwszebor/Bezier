//
//  AppDelegate.swift
//  Bezier
//
//  Created by Paweł Wszeborowski on 17/11/2018.
//  Copyright © 2018 Paweł Wszeborowski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window?.makeKeyAndOrderFront(nil)
        window?.minSize = CGSize(width: 350, height: 350)
        let root = MainViewController()
        window?.contentViewController = root
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

