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
    
    init(){
        self.passwordStoreUrl = URL(string: "test")!
        if let passwordStorePath = ProcessInfo.processInfo.environment["PASSWORD_STORE_DIR"] {
            self.passwordStoreUrl = URL(string: passwordStorePath)!
        } else {
            let userHome = ProcessInfo.processInfo.environment["HOME"]!
            self.passwordStoreUrl = URL(string: "\(userHome)/.password-store")!
        }
    }
    
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()
        
        let fileSystem = FileManager.default
        if let fsTree = fileSystem.enumerator(atPath: self.passwordStoreUrl.path) {
            // Iterate over all files and folders in the default store path. Several checks will be done.
            while let nodeName = fsTree.nextObject() as? String {
                
                var nodeNameComponents = nodeName.components(separatedBy: ".")
                if nodeNameComponents.last == "gpg" { // If there is a file extension
                  nodeNameComponents.removeLast()
                }
                
                let fsNodeName = nodeNameComponents.joined(separator: ".")
                
                let fullPath = "\(String(describing: self.passwordStoreUrl))\(fsNodeName)"
                let pathComponents = URL(fileURLWithPath: fullPath).pathComponents
                
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
        
        
        
        return resultPaths
    }
    
    func passShellCommand(passSubCommand: String) -> String {
        let shell = ProcessInfo.processInfo.environment["SHELL"]
        
        let task = Process()
        task.launchPath = shell
        task.arguments = ["-l", "-c", "pass \(passSubCommand)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }

    func passDecrypt(pathToFile: String) -> String {
        return passShellCommand(passSubCommand: pathToFile)
    }

    func passwordToClipboard(pathToFile: String) -> String {
        let subCommand = "-c \(pathToFile)"
        return passShellCommand(passSubCommand: subCommand)
    }
}
