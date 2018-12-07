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
    
    @IBOutlet weak var passPathTextField: NSTextField!
    @IBOutlet weak var passPathBrowseButton: NSButton!
    
    @IBOutlet weak var keyPathTextField: NSTextField!
    @IBOutlet weak var keyPathBrowseButton: NSButton!
    
    @IBOutlet weak var passphraseField: NSSecureTextField!

    @IBOutlet weak var showDockCheck: NSButton!
    let dockIconStateKey: String = "dockIconState"
    
    @IBOutlet weak var showStatusCheck: NSButton!
    let statusIconStateKey: String = "statusIconState"
    
    let isFirstRunKey: String = "firstRun"

    @IBAction func browsePassPath(_ sender: Any) {
        // Ask the user for the passwordstore path, remember it and init a passwordstore object.
        // This function is only used, if the user wants to change the path after the inital setup
        if let urlFromPanel = promptForPath(titleString: storeKey) {
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: storeKey)
            passPathTextField.stringValue = urlFromPanel.path
            passwordstore = Passwordstore(url: urlFromPanel)
        }
    }
    
    @IBAction func browseKeyPath(_ sender: Any) {
        // Ask the user for the key path, remember it and init the keyring.
        // This function is only used, if the user wants to change the path after the inital setup
        if let urlFromPanel = promptForPath(titleString: gpgKey) {
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: gpgKey)
            initKey(gpgKeyringPathUrl: urlFromPanel)
        }
    }
    
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
    
    func initPaths(forKey key: String) -> URL? {
        // If the path for the key is in the bookmarks, get it from there. Otherwise, we have to ask the user,
        // which is done in a separate function.
        let passPathUrlFromBookmark = sharedSecureBookmarkHandler.getPathFromBookmark(forKey: key)
        
        if passPathUrlFromBookmark == nil {
            return nil
        }
        
        return passPathUrlFromBookmark!
    }
    
    func initKey(gpgKeyringPathUrl: URL) {
        // Read the key from the URL and write it to the keyring
        let secKeyPath = gpgKeyringPathUrl.appendingPathComponent(privKeyFilename)
        keyPathTextField.stringValue = secKeyPath.path
        
        if gpgKeyringPathUrl.startAccessingSecurityScopedResource() {
            do {
                try passwordstore!.importKeys(keyFilePath: secKeyPath.path)
            } catch {
                os_log(.error, log: logger, "%s", "Can not import private key because \(error).")
                gpgKeyringPathUrl.stopAccessingSecurityScopedResource()
                return
            }
            gpgKeyringPathUrl.stopAccessingSecurityScopedResource()
        } else {
            return
        }
    }
    
    @IBAction func updatePassphrase(_ sender: Any) {
        let passphrase = passphraseField.stringValue
        if passphrase.isEmpty {
            // If the user decides to remove the passphrase from the keychain, we try to delete it.
            do {
                try deletePassphrase()
            } catch {
                os_log(.error, log: logger, "%s", "Could not delete the passphrase due to reason \(error).")
            }
        } else {
            do {
                // Here, two options are possible. There is already a passphrase.
                // Then try to update it.
                try Passafari.updatePassphrase(passphrase: passphrase)
            } catch {
                do {
                    // If the update fails, there seems to be no passphrase, so create a new one.
                    try storePassphrase(passphrase: passphrase)
                } catch {
                    os_log(.error, log: logger, "%s", "Could not store passphrase due to reason \(error).")
                }
            }
        }
    }
    
    func initApp() {
        // Init the passwordstore.
        if let passPathUrl = initPaths(forKey: storeKey) {
            passPathTextField.stringValue = passPathUrl.path
            passwordstore = Passwordstore(url: passPathUrl)
        }
        
        // Init the key
        let gpgKeyringPathUrl = initPaths(forKey: gpgKey)
        
        if gpgKeyringPathUrl != nil {
            initKey(gpgKeyringPathUrl: gpgKeyringPathUrl!)
        }
        
        do {
            passphraseField.stringValue = try searchPassphrase()
        } catch {
            os_log(.error, log: logger, "%s", "Error getting passphrase with reason \(error).")
        }
        
        showStatusItem()
        
        // Get dockicon and status bar icon states and set the icon visibilities accordingly.
        let dockIconState = UserDefaults.standard.bool(forKey: dockIconStateKey)
        if dockIconState {
            showDockCheck.state = .on
        } else {
            showDockCheck.state = .off
        }
        self.toggleDockIcon(showDockCheck)
        
        let statusIconState = UserDefaults.standard.bool(forKey: statusIconStateKey)
        if statusIconState {
            showStatusCheck.state = .on
        } else {
            showStatusCheck.state = .off
        }
        self.toggleStatusIcon(showStatusCheck)
    }
    
    override func viewDidAppear() {
        // Check, if the app is already set up.
        // If not, run the initial setup sheet.
        let alreadyRun = UserDefaults.standard.bool(forKey: isFirstRunKey)
        if !alreadyRun {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let firstRunWindowController = storyboard.instantiateController(withIdentifier: "FirstRun") as! NSWindowController
            
            if let firstRunWindow = firstRunWindowController.window {
                NSApplication.shared.mainWindow?.beginSheet(firstRunWindow, completionHandler: { (response) in
                    if response == NSApplication.ModalResponse.stop {
                        NSApp.terminate(self)
                    } else if response == NSApplication.ModalResponse.OK {
                        UserDefaults.standard.set(true, forKey: self.isFirstRunKey)
                        self.initApp()
                    }
                })
            }
        } else {
            initApp()
        }
        
    }
    
    @IBAction func showHelp(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/adur1990?tab=repositories")!)
    }
}
