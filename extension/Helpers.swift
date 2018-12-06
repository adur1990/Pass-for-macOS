//
//  Helpers.swift
//  extension
//
//  Created by Artur Sterz on 11.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation
import SafariServices
import os.log

let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Extension")

func fillPasswordFromSelection(pass: String? = nil) {
    let credentials: [String]
    let password: String
    let login: String
    var shortcut: String = "true"
    var message: String = ""
    
    var item = pass
    if pass == nil {
        if SafariExtensionViewController.shared.searchResultsTable.selectedRow < 0 {
            os_log(.error, log: logger, "%s", "Something went wrong. There are not results in the results table")
            return
        }
        item = resultsPasswords?[SafariExtensionViewController.shared.searchResultsTable.selectedRow]
        shortcut = ""
    }
    
    if item == "No matching password found." || item == "The Passafari app is not running." {
        password = ""
        login = ""
        message = item!
    } else {
        credentials = (sharedClientHandler.getPassword(passwordFile: item!)?.components(separatedBy: "\n"))!
        password = credentials[0]
        login = credentials[1].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    SFSafariApplication.getActiveWindow { (window) in
        window!.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.dispatchMessageToScript(withName: "credentials", userInfo: ["password": password, "login": login, "shortcut": shortcut, "message": message])
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
