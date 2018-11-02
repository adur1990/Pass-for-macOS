//
//  SafariExtensionViewController.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func searchPassword(_ sender: NSSearchField) {
        sharedClientHandler.executePasswordSearch(searchString: sender.stringValue)
    }
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:22)
        return shared
    }()

}
