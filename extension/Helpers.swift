//
//  Helpers.swift
//  extension
//
//  Created by Artur Sterz on 11.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation
import SafariServices

func fillPasswordFromSelection(pass: String? = nil) {
    var item = pass
    if pass == nil {
        if SafariExtensionViewController.shared.searchResultsTable.selectedRow < 0 {
            return
        }
        item = resultsPasswords?[SafariExtensionViewController.shared.searchResultsTable.selectedRow]
    }
    
    let credentials = sharedClientHandler.getPassword(passwordFile: item!)?.components(separatedBy: "\n")
    let password = credentials![0]
    let login = credentials![1].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)
    SFSafariApplication.getActiveWindow { (window) in
        window!.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.dispatchMessageToScript(withName: "credentials", userInfo: ["password" : password, "login": login])
            }
        }
    }
    if pass == nil {
        SafariExtensionViewController.shared.dismiss(SafariExtensionViewController.shared)
    }
}

func dispatchPasswordSearch(forURL urlHost: String, fromShortcut: Bool = false) {
    if fromShortcut {
        resultsPasswords = sharedClientHandler.searchPasswords(searchString: urlHost)
        let passwordToFill = resultsPasswords![0]
        fillPasswordFromSelection(pass: passwordToFill)
    } else {
        let popoverViewController = SafariExtensionViewController.shared
        let searchField = popoverViewController.searchField
        DispatchQueue.main.async {
            searchField!.window?.makeFirstResponder(nil)
            searchField!.stringValue = urlHost
            popoverViewController.searchPassword(searchField!)
            popoverViewController.showSearchResults()
        }
    }
}
