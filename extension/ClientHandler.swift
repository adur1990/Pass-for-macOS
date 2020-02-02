//Copyright 2018 Artur Sterz
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation
import os.log

let sharedClientHandler = ClientHandler()

class ClientHandler {
    func searchPasswords(searchString: String) -> [String]? {
        let data: CFData = CFDataCreate(nil, searchString, searchString.count)
        let messageID: sint32 = 0x1
        let sendTimeout: CFTimeInterval = 5
        let recvTimeout: CFTimeInterval = 60
        let remotePort: CFMessagePort? = CFMessagePortCreateRemote(nil, "group.de.artursterz.passformacos.messageport" as CFString)
        let returnDataPtr: UnsafeMutablePointer<Unmanaged<CFData>?> = UnsafeMutablePointer.allocate(capacity: 1)
        defer { returnDataPtr.deallocate() }
        
        if remotePort == nil {
            return ["Pass for macOS is not running."]
        }
        
        let status: sint32 = CFMessagePortSendRequest(remotePort, messageID, data, sendTimeout, recvTimeout, CFRunLoopMode.defaultMode.rawValue, returnDataPtr)
        
        if (status == kCFMessagePortSuccess) {
            let receivedData = returnDataPtr.pointee!.takeUnretainedValue() as Data
            let searchString = String(data: receivedData, encoding: .utf8)!
            return searchString.split(separator: ";").map {String($0)}
        } else {
            os_log(.error, log: logger, "%s", "Could not dispatch password search with state \(status)")
            return nil
        }
        
    }
    
    func getPassword(passwordFile: String) -> String? {
        let data: CFData = CFDataCreate(nil, passwordFile, passwordFile.count)
        let messageID: sint32 = 0x2
        let sendTimeout: CFTimeInterval = 5
        let recvTimeout: CFTimeInterval = 60
        let remotePort: CFMessagePort = CFMessagePortCreateRemote(nil, "group.de.artursterz.passformacos.messageport" as CFString)
        let returnDataPtr: UnsafeMutablePointer<Unmanaged<CFData>?> = UnsafeMutablePointer.allocate(capacity: 1)
        defer { returnDataPtr.deallocate() }
        
        let status: sint32 = CFMessagePortSendRequest(remotePort, messageID, data, sendTimeout, recvTimeout, CFRunLoopMode.defaultMode.rawValue, returnDataPtr)
        
        if (status == kCFMessagePortSuccess) {
            let receivedData = returnDataPtr.pointee!.takeUnretainedValue() as Data
            let decryptedPassword = String(data: receivedData, encoding: .utf8)!
            return decryptedPassword
        } else {
            os_log(.error, log: logger, "%s", "Could not dispatch password decryption with state \(status)")
            return nil
        }
        
    }
}
