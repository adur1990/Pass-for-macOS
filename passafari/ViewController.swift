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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlFromBookmark = sharedSecureBookmarkHandler.getPathFromBookmark()
        passwordstore = Passwordstore(score: 0.3, url: urlFromBookmark!)
        
        if urlFromBookmark == nil {
            if let urlFromPanel = promptForPath() {
                sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel)
                passwordstore = Passwordstore(score: 0.3, url: urlFromPanel)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
