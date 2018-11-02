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
                    DispatchQueue.main.async {
                        SafariExtensionViewController.shared.searchField.window?.makeFirstResponder(nil)
                        SafariExtensionViewController.shared.searchField.stringValue = urlHost!
                        sharedClientHandler.executePasswordSearch(searchString: urlHost!)
                    }
                }
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
