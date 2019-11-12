//
//  SafariExtensionHandler.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { pageProperties in
            // search password, if the shordcut was used.
            if messageName == "fillShortcutPressed" {
                let urlHost = pageProperties!.url?.host
                var urlHostComponents = urlHost!.split(separator: ".")
                if urlHostComponents.first == "www" {
                    urlHostComponents.removeFirst()
                }
                let url = urlHostComponents.joined(separator: ".")
                let passwordToFill = sharedClientHandler.searchPasswords(searchString: url)![0]
                
                let credentials: [String]
                let password: String
                var login: String = ""
                var message: String = ""
                
                if passwordToFill == "No matching password found." || passwordToFill == "The Passafari app is not running." {
                    password = ""
                    login = ""
                    message = passwordToFill
                } else {
                    credentials = (sharedClientHandler.getPassword(passwordFile: passwordToFill)?.components(separatedBy: "\n"))!
                    password = credentials[0]

                    if credentials.count > 1 {
                        if credentials[1].count > 0 {
                            let loginDirty = credentials[1].drop(while: {$0 != ":"})
                            login = String(loginDirty.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
                
                SFSafariApplication.getActiveWindow { (window) in
                    window!.getActiveTab { (activeTab) in
                        activeTab!.getActivePage { (activePage) in
                            activePage!.dispatchMessageToScript(withName: "credentials", userInfo: ["password": password, "login": login, "shortcut": "true", "message": message])
                        }
                    }
                }
            }
        }
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.getPropertiesWithCompletionHandler { (pageProperties) in
                    // search password, if the toolbar item was clicked
                    let urlHost = pageProperties!.url?.host
                    
                    var urlHostComponents = urlHost!.split(separator: ".")
                    if urlHostComponents.first == "www" {
                        urlHostComponents.removeFirst()
                    }
                    let url = urlHostComponents.joined(separator: ".")
                    
                    let popoverViewController = SafariExtensionViewController.shared
                    let searchField = popoverViewController.searchField
                    DispatchQueue.main.async {
                        searchField!.window?.makeFirstResponder(nil)
                        searchField!.stringValue = url
                        popoverViewController.searchPassword(searchField!)
                        popoverViewController.showSearchResults()
                    }
                }
            }
        }
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        SafariExtensionViewController.shared.resetPopover()
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
