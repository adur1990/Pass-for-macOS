//
//  AppDelegate.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

import SafariServices

var passwordstore: Passwordstore? = nil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem : NSStatusItem? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = ServerHandler()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(named: "statusIcon")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitApp), keyEquivalent: ""))
        statusBarItem?.menu = menu
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
