//
//  ViewController.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa
import os.log

class ViewController: NSViewController {
    var statusBarItem : NSStatusItem? = nil

    @IBOutlet weak var showDockCheck: NSButton!
    let dockIconStateKey: String = "dockIconState"
    
    @IBOutlet weak var showStatusCheck: NSButton!
    let statusIconStateKey: String = "statusIconState"
    
    @IBAction func toggleDockIcon(_ sender: Any) {
        // Toggles, if the dock icon should be visible and remembers the state.
        let defaults = UserDefaults.standard
        if showDockCheck.state == .on {
            defaults.set(true, forKey: dockIconStateKey)
            defaults.synchronize()
            NSApp.setActivationPolicy(.regular)
        } else if showDockCheck.state == .off {
            defaults.set(false, forKey: dockIconStateKey)
            defaults.synchronize()
            NSApp.setActivationPolicy(.accessory)
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.forEach { $0.makeKeyAndOrderFront(self) }
            }
        }
    }
    
    @IBAction func toggleStatusIcon(_ sender: Any) {
        // Toggles, if the status bar icon should be visible and remembers the state.
        let defaults = UserDefaults.standard
        if showStatusCheck.state == .on {
            defaults.set(true, forKey: statusIconStateKey)
            defaults.synchronize()
            showStatusItem()
        } else if showStatusCheck.state == .off {
            defaults.set(false, forKey: statusIconStateKey)
            defaults.synchronize()
            NSStatusBar.system.removeStatusItem(statusBarItem!)
        }
    }
    
    func showStatusItem() {
        // If the status bar icon should be visible, we have to build the menu manually.
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(named: "statusIcon")
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show", action: #selector(AppDelegate.revealWindow), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitApp), keyEquivalent: "q"))
        statusBarItem?.menu = menu
    }
    
    override func viewDidAppear() {
        passwordstore = Passwordstore()

        showStatusItem()

        // Get dockicon and status bar icon states and set the icon visibilities accordingly.
        let dockIconState = UserDefaults.standard.bool(forKey: dockIconStateKey)
        if dockIconState {
            showDockCheck.state = .on
        } else {
            showDockCheck.state = .off
        }
        self.toggleDockIcon(showDockCheck as Any)

        let statusIconState = UserDefaults.standard.bool(forKey: statusIconStateKey)
        if statusIconState {
            showStatusCheck.state = .on
        } else {
            showStatusCheck.state = .off
        }
        self.toggleStatusIcon(showStatusCheck as Any)
        
    }
}
