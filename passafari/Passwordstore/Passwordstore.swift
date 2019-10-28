//
//  Passwordstore.swift
//  passafari
//
//  Created by Artur Sterz on 28.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation
import os.log

class Passwordstore {
    var passwordStoreUrl: URL
    
    init(url passwordStoreUrl: URL){
        self.passwordStoreUrl = passwordStoreUrl
    }
    
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()
        
        // Start accessing the user provided path to the passwordstore and get all files in it.
        if self.passwordStoreUrl.startAccessingSecurityScopedResource() {
            let fileSystem = FileManager.default
            if let fsTree = fileSystem.enumerator(atPath: self.passwordStoreUrl.path) {
                // Iterate over all files and folders in the default store path. Several checks will be done.
                while let fsNodeName = fsTree.nextObject() as? String {
                    let fullPath = "\(String(describing: self.passwordStoreUrl))\(fsNodeName)"
                    var pathComponents = URL(fileURLWithPath: fullPath).pathComponents
                    
                    // To not accidentally exclude a valid encrypted file from the search path, we remove it beforehand from the .git search components.
                    if pathComponents.last!.hasSuffix(".gpg") {
                        pathComponents.removeLast()
                    } else {
                        continue
                    }
                    
                    // If a password store is a git folder, we do not want to iterate over the entire repository, but only the current copy.
                    // Therefore, we need to exclude all folders containing .git from the search items.
                    if pathComponents.contains(where:
                        { (pathComponent) -> Bool in
                            return pathComponent.contains(".git")
                    }) {
                        continue
                    }

                    // This is the search. Just check, if the password is in the fullpath.
                    if fullPath.localizedCaseInsensitiveContains(password) {
                        resultPaths.append(fsNodeName)
                    }
                }
            }
        }
        
        // In this case, no password could be found. This can be due to subdomains.
        // If you have a password for apple.com, but not secure.apple.com, the latter would
        // not be found. Using this part, the secure. prefix will be removed and apple.com will be searched.
        if resultPaths.isEmpty {
            let passwordParts = password.components(separatedBy: ".")
            
            if passwordParts.count > 2 {
                let shortPassword = passwordParts.suffix(2).joined(separator: ".")
                return passSearch(password: shortPassword)
            }
        }
        
        self.passwordStoreUrl.stopAccessingSecurityScopedResource()
        
        return resultPaths
    }
    
    func passDecrypt(pathToFile: String) -> String {
        // This function dispatches the decryption. Read below for more information...
        return ""
    }
}
