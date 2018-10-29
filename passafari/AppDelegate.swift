//
//  AppDelegate.swift
//  passafari
//
//  Created by Artur Sterz on 10.10.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

import SafariServices

var passwordstore: Passwordstore? = nil

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func exampleHandler() -> CFMessagePortCallBack {
        return { (messagePort: CFMessagePort?, messageID: Int32, data: CFData?, info: UnsafeMutableRawPointer?) -> Unmanaged<CFData>? in
            let receivedData = data! as Data
            let searchString = String(data: receivedData, encoding: .utf8)!
            
            print("##### \(searchString)")
            print("##### \(passwordstore!.passwordStoreUrl.path)")
            
            var foundPasswords = passwordstore!.passSearch(password: searchString)
            
            if foundPasswords.isEmpty {
                foundPasswords = ["No matching password found."]
            }
            print(foundPasswords)
            
            let returnPasswords = foundPasswords.joined(separator: ";")
            
            let returnData = CFDataCreate(nil, returnPasswords, returnPasswords.count)!
            
            return Unmanaged.passRetained(returnData)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let port = CFMessagePortCreateLocal(nil, "BR355MFMD5.de.artursterz.passafari.messageport" as CFString, exampleHandler(), nil, nil)
        let runLoopSource = CFMessagePortCreateRunLoopSource(nil, port, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
