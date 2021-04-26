//Copyright 2018 Artur Sterz
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation
import os.log

class Passwordstore {
    var passwordStoreUrl: URL
    
    init(){
        let shell = ProcessInfo.processInfo.environment["SHELL"]
        let task = Process()
        task.launchPath = shell
        task.arguments = ["-i", "-c", "echo $PASSWORD_STORE_DIR"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        self.passwordStoreUrl = URL(string: "test")!

        if data.count > 1 {
            var passwordStorePath = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            passwordStorePath = passwordStorePath.trimmingCharacters(in: .newlines)
            self.passwordStoreUrl = URL(string: passwordStorePath)!
        } else {
            let userHome = ProcessInfo.processInfo.environment["HOME"]!
            self.passwordStoreUrl = URL(string: "\(userHome)/.password-store")!
        }

        // This checks, if password store is a symlink and resolves it, if so.
        // TODO: this is currently a work-around, as I did not find any way to do
        // it in pure swift. The function resolveSymLink calls the readlink binary.
        let resolved = resolveSymLink(path: self.passwordStoreUrl.absoluteString)
        if !resolved.isEmpty {
            self.passwordStoreUrl = URL(string: "\(resolved.filter { !$0.isWhitespace })")!
        }
    }
    
    func passSearch(password: String) -> [String] {
        var resultPaths = [String]()

        let fileSystem = FileManager.default
        if let fsTree = fileSystem.enumerator(at: self.passwordStoreUrl, includingPropertiesForKeys: [.isRegularFileKey]) {
            // Iterate over all files and folders in the default store path. Several checks will be done.
            while let nodeUrl = fsTree.nextObject() as? URL {
                let nodeName = nodeUrl.path
                let pathComponents = URL(fileURLWithPath: nodeName).pathComponents
                
                // If a password store is a git folder, we do not want to iterate over the entire repository, but only the current copy.
                // Therefore, we need to exclude all folders containing .git from the search items.
                if pathComponents.contains(where:
                    { (pathComponent) -> Bool in
                        return pathComponent.contains(".git")
                }) {
                    continue
                }

                do {
                    let fileAttributes = try nodeUrl.resourceValues(forKeys:[.isRegularFileKey])
                    if !fileAttributes.isRegularFile! {
                        continue
                    }
                } catch {
                    print(error, nodeUrl)
                }

                // This is the search. Just check, if the password is in the fullpath.
                if nodeName.localizedCaseInsensitiveContains(password) {
                    if nodeUrl.pathExtension != "gpg" {
                        continue
                    }
                    let extRemoved = nodeUrl.pathExtension == "gpg" ? nodeUrl.deletingPathExtension().path : nodeName
                    resultPaths.append(extRemoved.replacingOccurrences(of: self.passwordStoreUrl.path + "/", with: ""))
                }
            }
        }
        
        // In this case, no password could be found. This can be due to subdomains.
        // If you have a password for apple.com, but not secure.apple.com, the latter would
        // not be found. Using this part, the secure. prefix will be removed and apple.com will be searched.
        if resultPaths.isEmpty {
            let passwordParts = password.components(separatedBy: ".")
            if passwordParts.count > 2 {
                let shortPassword = passwordParts.dropFirst().joined(separator: ".")
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

    func resolveSymLink(path: String) -> String {
        let shell = ProcessInfo.processInfo.environment["SHELL"]

        let task = Process()
        task.launchPath = shell
        task.arguments = ["-l", "-c", "readlink \(path)"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }
}
