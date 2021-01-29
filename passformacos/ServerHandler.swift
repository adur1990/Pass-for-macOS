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

class ServerHandler {
    // This class handles the host's server part of the mach port communication between the extension and the host app.
    init() {
        let port = CFMessagePortCreateLocal(nil, "group.de.artursterz.passformacos.messageport" as CFString, serverHandler(), nil, nil)
        let runLoopSource = CFMessagePortCreateRunLoopSource(nil, port, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
    }
    
    func serverHandler() -> CFMessagePortCallBack {
        return { (messagePort: CFMessagePort?, messageID: Int32, data: CFData?, info: UnsafeMutableRawPointer?) -> Unmanaged<CFData>? in
            
            // Search
            if messageID == 0x1 {
                let receivedData = data! as Data
                let searchString = String(data: receivedData, encoding: .utf8)!
                
                var foundPasswords = passwordstore!.passSearch(password: searchString)
                
                if foundPasswords.isEmpty {
                    foundPasswords = ["No password found."]
                }
                
                // This is a fairly simple serialization for the mach port. Just make a big string containing all passwords seperated by ;
                let returnPasswords = foundPasswords.joined(separator: ";")
                
                let returnData = CFDataCreate(nil, returnPasswords, returnPasswords.count)!
                
                return Unmanaged.passRetained(returnData)
            } else
                // Decrypt
            if messageID == 0x2 {
                let receivedData = data! as Data
                let passwordFile = String(data: receivedData, encoding: .utf8)!
                
                let decryptedPassword = passwordstore!.passDecrypt(pathToFile: passwordFile)
                let returnData = CFDataCreate(nil, decryptedPassword, decryptedPassword.count)!
                
                return Unmanaged.passRetained(returnData)
            }
            
            return Unmanaged.passRetained(data!)
        }
    }
}
