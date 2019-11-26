//
//  AppDelegate.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa
import Carbon

import SafariServices

var passwordstore: Passwordstore? = nil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = ServerHandler()

        passwordstore = Passwordstore()

        if let button = statusBarItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = #selector(togglePopover(_:))
        }

        popover.contentViewController = ViewController.newController()
        popover.behavior = NSPopover.Behavior.transient;

        Shortcut.register(
            UInt32(kVK_ANSI_P),
            modifiers: UInt32((shiftKey | controlKey)),
            block: {
                self.togglePopover(nil)
            }
        )
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func togglePopover(_ sender: Any?) {
      if popover.isShown {
        closePopover(sender: sender)
      } else {
        showPopover(sender: sender)
      }
    }

    func showPopover(sender: Any?) {
      if let button = statusBarItem.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
    }
}

extension ViewController {
  static func newController() -> ViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("ViewController")

    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
      fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}
