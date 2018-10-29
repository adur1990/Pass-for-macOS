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
    
    func getPathFromBookmark() -> URL? {
        if let data = UserDefaults.standard.data(forKey: "passPathBookmark") {
            var bookmarkDataIsStale: ObjCBool = false
            
            let url = try! (NSURL(resolvingBookmarkData: data, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) as URL)
            if bookmarkDataIsStale.boolValue {
                print("WARNING stale security bookmark")
                return nil
            }
            return url
        }
        return nil
    }
    
    func savePathToBookmark(url: URL) {
        let data = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: "passPathBookmark")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlFromBookmark = getPathFromBookmark()
        passwordstore = Passwordstore(score: 0.3, url: urlFromBookmark!)
        
        if urlFromBookmark == nil {
            if let urlFromPanel = promptForPath() {
                savePathToBookmark(url: urlFromPanel)
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
