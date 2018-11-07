//
//  ClientHandler.swift
//  extension
//
//  Created by Artur Sterz on 02.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation

let sharedClientHandler = ClientHandler()

class ClientHandler {
    func searchPasswords(searchString: String) -> [String]? {
        let data: CFData = CFDataCreate(nil, searchString, searchString.count)
        let messageID: sint32 = 0x1
        let timeout: CFTimeInterval = 1
        let remotePort: CFMessagePort = CFMessagePortCreateRemote(nil, "BR355MFMD5.de.artursterz.passafari.messageport" as CFString)
        let returnDataPtr: UnsafeMutablePointer<Unmanaged<CFData>?> = UnsafeMutablePointer.allocate(capacity: 1)
        defer { returnDataPtr.deallocate() }
        
        let status: sint32 = CFMessagePortSendRequest(remotePort, messageID, data, timeout, timeout, CFRunLoopMode.defaultMode.rawValue, returnDataPtr)
        
        if (status == kCFMessagePortSuccess) {
            let receivedData = returnDataPtr.pointee!.takeUnretainedValue() as Data
            let searchString = String(data: receivedData, encoding: .utf8)!
            return searchString.split(separator: ";").map {String($0)}
        } else {
            return nil
        }
        
    }
    
    func getPassword(passwordFile: String) -> String? {
        let data: CFData = CFDataCreate(nil, passwordFile, passwordFile.count)
        let messageID: sint32 = 0x2
        let timeout: CFTimeInterval = 1
        let remotePort: CFMessagePort = CFMessagePortCreateRemote(nil, "BR355MFMD5.de.artursterz.passafari.messageport" as CFString)
        let returnDataPtr: UnsafeMutablePointer<Unmanaged<CFData>?> = UnsafeMutablePointer.allocate(capacity: 1)
        defer { returnDataPtr.deallocate() }
        
        let status: sint32 = CFMessagePortSendRequest(remotePort, messageID, data, timeout, timeout, CFRunLoopMode.defaultMode.rawValue, returnDataPtr)
        
        if (status == kCFMessagePortSuccess) {
            let receivedData = returnDataPtr.pointee!.takeUnretainedValue() as Data
            let decryptedPassword = String(data: receivedData, encoding: .utf8)!
            return decryptedPassword
        } else {
            return nil
        }
        
    }
}
