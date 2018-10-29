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
        self.executePasswordSearch(searchString: sender.stringValue)
    }
    
    @objc func handleMessageFromContainingApp(notif: Notification) {
        let resultPasswordList = notif.userInfo!["passwords"] as! [String]
        
        NSLog(resultPasswordList.joined())
    }
    
    func executePasswordSearch(searchString: String) {
        let data: CFData = CFDataCreate(nil, searchString, searchString.count)
        let messageID: sint32 = 0x1111
        let timeout: CFTimeInterval = 1
        let remotePort: CFMessagePort = CFMessagePortCreateRemote(nil, "BR355MFMD5.de.artursterz.passafari.messageport" as CFString)
        let returnDataPtr: UnsafeMutablePointer<Unmanaged<CFData>?> = UnsafeMutablePointer.allocate(capacity: 1)
        defer { returnDataPtr.deallocate() }
        
        let status: sint32 = CFMessagePortSendRequest(remotePort, messageID, data, timeout, timeout, CFRunLoopMode.defaultMode.rawValue, returnDataPtr)
        
        if (status == kCFMessagePortSuccess)
        {
            let receivedData = returnDataPtr.pointee!.takeUnretainedValue() as Data
            let searchString = String(data: receivedData, encoding: .utf8)!
            NSLog("######### SUCCESS STATUS \(searchString)");
        }
        else
        {
            NSLog("######### FAIL STATUS");
        }

    }
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:330, height:22)
        return shared
    }()

}
