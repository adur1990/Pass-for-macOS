//
//  SafariExtensionHandler.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.getPropertiesWithCompletionHandler { (pageProperties) in
                    let urlHost = pageProperties!.url?.host
                    let popoverViewController = SafariExtensionViewController.shared
                    let searchField = popoverViewController.searchField
                    DispatchQueue.main.async {
                        searchField!.window?.makeFirstResponder(nil)
                        searchField!.stringValue = urlHost!
                        popoverViewController.searchPassword(searchField!)
                    }
                }
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
