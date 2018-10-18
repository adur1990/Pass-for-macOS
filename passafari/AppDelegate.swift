//
//  AppDelegate.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

import SafariServices

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let FUZZY_SEARCH_SCORE = 0.3
    
    /*
     We need the path to the default password store. As of writing this, we only accept the default path, which is $HOME/.password-store/
    */
    private var passwordStoreUrl: NSURL? {
        let pw = getpwuid(getuid())
        let home = pw?.pointee.pw_dir
        let homePath = FileManager.default.string(withFileSystemRepresentation: home!, length: Int(strlen(home)))
        let homePathUrl = NSURL(string: "\(homePath)/.password-store/")
        
        return homePathUrl
    }
    
    /*
     The GPG key ID needed for decrypting the password file.
    */
    private var gpgKeyId: String {
        do {
            return try String(contentsOfFile: passwordStoreUrl!.appendingPathComponent(".gpg-id")!.absoluteString, encoding: .utf8)
        }
        catch {
            return "nil"
        }
    }
    
    /*
     Main password search function. This will be used for searching passwords from the default store path.
     We use a fuzzy search in all cases.
    */
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()
        
        let fileSystem = FileManager.default
        if let fsTree = fileSystem.enumerator(atPath: passwordStoreUrl!.absoluteString!) {
            
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
        
        return resultPaths
    }
    
    @objc func handleMessageFromContainingApp(notif: Notification) {
        print(passSearch(password: notif.object as! String))
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let center = DistributedNotificationCenter.default()
        center.addObserver(self, selector: #selector(self.handleMessageFromContainingApp(notif:)), name: Notification.Name("search"), object: nil)
        // Insert code here to tear down your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

