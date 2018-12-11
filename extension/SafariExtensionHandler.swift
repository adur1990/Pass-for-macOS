//
//  SafariExtensionHandler.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

var resultsPasswords: [String]?

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    func dispatchPasswordSearch(forURL urlHost: String, fromShortcut: Bool = false) {
        var urlHostComponents = urlHost.split(separator: ".")
        if urlHostComponents[0] == "www" {
            urlHostComponents.remove(at: 0)
        }
        let url = urlHostComponents.joined(separator: ".")
        
        if fromShortcut {
            resultsPasswords = sharedClientHandler.searchPasswords(searchString: url)
            let passwordToFill = resultsPasswords![0]
            SafariExtensionViewController.shared.fillPasswordFromSelection(pass: passwordToFill)
        } else {
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
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { pageProperties in
            // search password, if the shordcut was used.
            if messageName == "fillShortcutPressed" {
                let urlHost = pageProperties!.url?.host
                self.dispatchPasswordSearch(forURL: urlHost!, fromShortcut: true)
            }
        }
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.getPropertiesWithCompletionHandler { (pageProperties) in
                    // search password, if the toolbar item was clicked
                    let urlHost = pageProperties!.url?.host
                    
                    self.dispatchPasswordSearch(forURL: urlHost!)
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
