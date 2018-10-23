//
//  ViewController.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let FUZZY_SEARCH_SCORE = 0.3
    
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()
        
        let passwordStoreUrl = getPathFromBookmark()
        
        if passwordStoreUrl!.startAccessingSecurityScopedResource() {
            let fileSystem = FileManager.default
            if let fsTree = fileSystem.enumerator(atPath: passwordStoreUrl!.path) {
                // Iterate over all files and folders in the default store path. Several checks will be done.
                while let fsNodeName = fsTree.nextObject() as? String {
                    let fullPath = "\(String(describing: passwordStoreUrl!))\(fsNodeName)"
                    var pathComponents = URL(fileURLWithPath: fullPath).pathComponents
                    
                    // To not accidentally exclude a valid encrypted file from the search path, we remove it beforehand from the .git search components.
                    if pathComponents.last!.hasSuffix(".gpg") {
                        pathComponents.removeLast()
                    } else {
                        continue
                    }
                    
                    // If a password store is a git folder, we do not want to iterate over the entire repository, but only the current working copy.
                    // Therefore, we need to exclude all folders containing .git from the search items.
                    if pathComponents.contains(where:
                        { (pathComponent) -> Bool in
                            return pathComponent.contains(".git")
                    }) {
                        continue
                    }
                    
                    // The final scoring. If a path matches at least FUZZY_SEARCH_SCORE, we remember it.
                    if FuzzySearch.score(originalString:fullPath, stringToMatch: password) > FUZZY_SEARCH_SCORE {
                        resultPaths.append(fsNodeName)
                    }
                }
            }
        }
        
        passwordStoreUrl!.stopAccessingSecurityScopedResource()
        
        return resultPaths
    }
    
    //@objc func handleMessageFromContainingApp(notif: Notification) {
    //    var foundPasswords = passSearch(password: notif.object as! String)
    //    if foundPasswords.isEmpty {
    //        foundPasswords = ["No matching password found."]
    //    }
    //    print(foundPasswords)
    //}
    
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
        
        if urlFromBookmark == nil {
            if let urlFromPanel = promptForPath() {
                savePathToBookmark(url: urlFromPanel)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
