//
//  ViewController.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {    
    func promptForPath() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.showsHiddenFiles = true
        openPanel.title = "Select password-store default store"
        
        if openPanel.runModal() == NSApplication.ModalResponse.OK && !openPanel.urls.isEmpty {
            return openPanel.url
        }
        return nil
    }
    
    func initPaths(forKey key: String) -> URL {
        let passPathUrlFromBookmark = sharedSecureBookmarkHandler.getPathFromBookmark(forKey: key)
        
        if passPathUrlFromBookmark == nil {
            if let urlFromPanel = promptForPath() {
                sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: key)
                return urlFromPanel
            }
        }
        
        return passPathUrlFromBookmark!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let passPathUrl = initPaths(forKey: "passPathBookmark")
        passwordstore = Passwordstore(score: 0.3, url: passPathUrl)     
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
