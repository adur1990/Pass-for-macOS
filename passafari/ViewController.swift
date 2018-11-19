//
//  ViewController.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var passPathTextField: NSTextField!
    @IBOutlet weak var passPathBrowseButton: NSButton!
    
    @IBOutlet weak var keyPathTextField: NSTextField!
    @IBOutlet weak var keyPathBrowseButton: NSButton!
    
    
    @IBAction func browsePassPath(_ sender: Any) {
        let key = "password-store"
        
        if let urlFromPanel = promptForPath(titleString: key) {
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: key)
            passPathTextField.stringValue = urlFromPanel.path
            passwordstore = Passwordstore(score: 0.3, url: urlFromPanel)
        }
    }
    
    @IBAction func browseKeyPath(_ sender: Any) {
        let key = "GPG folder"
        
        if let urlFromPanel = promptForPath(titleString: key) {
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: key)
            initKey(gpgKeyringPathUrl: urlFromPanel)
        }
    }
    
    
    func promptForPath(titleString: String) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.showsHiddenFiles = true
        openPanel.title = "Select path for \(titleString)."
        
        if openPanel.runModal() == NSApplication.ModalResponse.OK && !openPanel.urls.isEmpty {
            return openPanel.url
        }
        return nil
    }
    
    func initPaths(forKey key: String) -> URL? {
        let passPathUrlFromBookmark = sharedSecureBookmarkHandler.getPathFromBookmark(forKey: key)
        
        if passPathUrlFromBookmark == nil {
            return nil
        }
        
        return passPathUrlFromBookmark!
    }
    
    func initKey(gpgKeyringPathUrl: URL) {
        let secKeyPath = gpgKeyringPathUrl.appendingPathComponent("private")
        keyPathTextField.stringValue = secKeyPath.path
        
        if gpgKeyringPathUrl.startAccessingSecurityScopedResource() {
            do {
                try passwordstore!.importKeys(keyFilePath: secKeyPath.path)
            } catch {
                return
            }
            gpgKeyringPathUrl.stopAccessingSecurityScopedResource()
        } else {
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let passPathUrl = initPaths(forKey: "password-store") {
            passPathTextField.stringValue = passPathUrl.path
            passwordstore = Passwordstore(score: 0.3, url: passPathUrl)
        }
        
        let gpgKeyringPathUrl = initPaths(forKey: "GPG folder")
        
        if gpgKeyringPathUrl == nil {
            return
        }
        
        initKey(gpgKeyringPathUrl: gpgKeyringPathUrl!)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
