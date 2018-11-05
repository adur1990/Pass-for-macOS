//
//  Server.swift
//  passafari
//
//  Created by Artur Sterz on 02.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation

class ServerHandler {
    init() {
        let port = CFMessagePortCreateLocal(nil, "BR355MFMD5.de.artursterz.passafari.messageport" as CFString, serverHandler(), nil, nil)
        let runLoopSource = CFMessagePortCreateRunLoopSource(nil, port, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
    }
    
    func serverHandler() -> CFMessagePortCallBack {
        return { (messagePort: CFMessagePort?, messageID: Int32, data: CFData?, info: UnsafeMutableRawPointer?) -> Unmanaged<CFData>? in
            
            if messageID == 0x1 {
                let receivedData = data! as Data
                let searchString = String(data: receivedData, encoding: .utf8)!
                
                var foundPasswords = passwordstore!.passSearch(password: searchString)
                
                if foundPasswords.isEmpty {
                    foundPasswords = ["No matching password found."]
                }
                print(foundPasswords)
                
                let returnPasswords = foundPasswords.joined(separator: ";")
                
                let returnData = CFDataCreate(nil, returnPasswords, returnPasswords.count)!
                
                return Unmanaged.passRetained(returnData)
            } else if messageID == 0x2 {
                let receivedData = data! as Data
                let passwordString = String(data: receivedData, encoding: .utf8)!
                
                print("### \(passwordString)")
                
                //var foundPasswords = passwordstore!.passSearch(password: searchString)
                
                
                let returnData = CFDataCreate(nil, "!", 1)!
                
                return Unmanaged.passRetained(returnData)
            }
            
            return Unmanaged.passRetained(data!)
        }
    }
}
