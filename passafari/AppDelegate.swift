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
    
    private var passwordStoreUrl: NSURL? {
        let pw = getpwuid(getuid())
        let home = pw?.pointee.pw_dir
        let homePath = FileManager.default.string(withFileSystemRepresentation: home!, length: Int(strlen(home)))
        let homePathUrl = NSURL(string: "\(homePath)/.password-store/")
        
        return homePathUrl
    }
    
    private var gpgKeyId: String {
        do {
            return try String(contentsOfFile: passwordStoreUrl!.appendingPathComponent(".gpg-id")!.absoluteString, encoding: .utf8)
        }
        catch {
            return "nil"
        }
    }
    
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()
        
        let fileSystem = FileManager.default
        if let fsTree = fileSystem.enumerator(atPath: passwordStoreUrl!.absoluteString!) {
            
            while let fsNodeName = fsTree.nextObject() as? String {
                let fullPath = "\(String(describing: passwordStoreUrl))/\(fsNodeName)"
                var isDir: ObjCBool = false
                fileSystem.fileExists(atPath: fullPath, isDirectory: &isDir)
                
                if !isDir.boolValue && fsNodeName.contains(password) {
                    resultPaths.append(fsNodeName)
                }
            }
        }
        
        return resultPaths
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

