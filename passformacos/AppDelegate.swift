//Copyright 2018 Artur Sterz
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Cocoa

import SafariServices

import Sparkle
import KeyboardShortcuts
import Preferences

var passwordstore: Passwordstore? = nil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    let popover = NSPopover()

    var contextMenu = NSMenu()

    lazy var preferencesWindowController = PreferencesWindowController(
            preferencePanes: [
                GeneralPreferencesViewController(),
                UpdatePreferencesViewController()
            ],
            style: .segmentedControl
        )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = ServerHandler()

        passwordstore = Passwordstore()

        if let button = statusBarItem.button {
            button.image = NSImage(named: "statusIcon")
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let versionItem = NSMenuItem()
        versionItem.title = "Pass for macOS v\(version)"
        versionItem.isEnabled = false

        contextMenu.addItem(versionItem)
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(withTitle: "Preferences...", action: #selector(showPreferences(_:)), keyEquivalent: ",")
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        popover.contentViewController = ViewController.newController()
        popover.behavior = NSPopover.Behavior.transient

        KeyboardShortcuts.onKeyUp(for: .togglePopupShortcut) { [self] in
            self.handleShortcut(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func handleShortcut(_ sender: Any?) {
        if safariIsActive() {
            SFSafariApplication.dispatchMessage(withName: "fillShortcutPressed", toExtensionWithIdentifier: "de.artursterz.passformacos.extension", userInfo: nil, completionHandler: nil)
        } else {
            self.togglePopover(nil)
        }
    }

    func safariIsActive() -> Bool {
        // Get the app that currently has the focus.
        let frontApp = NSWorkspace.shared.frontmostApplication!

        // Check if the front most app is Safari
        if frontApp.bundleIdentifier == "com.apple.Safari" {
            // If it is Safari, it still does not mean, that is receiving key events
            // (i.e., has a window at the front).
            // But what we can safely say is, that if Safari is the front most app
            // and it has at least one window, it has to be the window that
            // crrently receives key events.
            let safariPID = frontApp.processIdentifier

            // With this procedure, we get all available windows.
            let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
            let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
            let windowInfoList = windowListInfo as NSArray? as? [[String: AnyObject]]

            // Now that we have all available windows, we are going to check if at least one of them
            // is owned by Safari.
            for info in windowInfoList! {
                let windowPID = info["kCGWindowOwnerPID"] as! UInt32
                if  windowPID == safariPID {
                    return true
                }
            }
        }
        return false
    }

    @objc func togglePopover(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = contextMenu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil
        } else {
            if popover.isShown {
              closePopover(sender: sender)
            } else {
              showPopover(sender: sender)
            }
        }
    }

    @objc func showPreferences(_ sender: Any?) {
        preferencesWindowController.show()
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
