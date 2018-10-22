//
//  SafariExtensionViewController.swift
//  extension
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    let center = DistributedNotificationCenter.default()
    
    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func searchPassword(_ sender: NSSearchField) {
        self.executePasswordSearch(searchString: sender.stringValue)
    }
    
    @objc func handleMessageFromContainingApp(notif: Notification) {
        let resultPasswordList = notif.userInfo!["passwords"] as! [String]
        
        NSLog(resultPasswordList.joined())
    }
    
    func executePasswordSearch(searchString: String) {
        center.postNotificationName(Notification.Name("search"), object: searchString, userInfo: nil, deliverImmediately: true)
    }
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:22)
        return shared
    }()

}
