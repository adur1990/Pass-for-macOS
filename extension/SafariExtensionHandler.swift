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
        let center = DistributedNotificationCenter.default()
        center.postNotificationName(Notification.Name("search"), object: "uberspace", userInfo: nil, deliverImmediately: true)
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        let center = DistributedNotificationCenter.default()
        
        window.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.getPropertiesWithCompletionHandler { (pageProperties) in
                    let urlHost = pageProperties!.url?.host
                    DispatchQueue.main.async {
                        SafariExtensionViewController.shared.textField.window?.makeFirstResponder(nil)
                        SafariExtensionViewController.shared.textField.stringValue = urlHost!
                    }
                    center.postNotificationName(Notification.Name("search"), object: urlHost, userInfo: nil, deliverImmediately: true)
                }
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
