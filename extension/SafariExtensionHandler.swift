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

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        page.getPropertiesWithCompletionHandler { pageProperties in
            // search password, if the shordcut was used.
            if messageName == "fillShortcutPressed" {
                let urlHost = pageProperties!.url?.host
                var urlHostComponents = urlHost!.split(separator: ".")
                if urlHostComponents.first == "www" {
                    urlHostComponents.removeFirst()
                }
                let url = urlHostComponents.joined(separator: ".")
                let passwordToFill = sharedClientHandler.searchPasswords(searchString: url)![0]
                
                let credentials: [String]
                let password: String
                var login: String = ""
                var message: String = ""
                
                if passwordToFill == "No matching password found." || passwordToFill == "Pass for macOS is not running." {
                    password = ""
                    login = ""
                    message = passwordToFill
                } else {
                    credentials = (sharedClientHandler.getPassword(passwordFile: passwordToFill)?.components(separatedBy: "\n"))!
                    password = credentials[0]

                    if credentials.count > 1 {
                        if credentials[1].count > 0 {
                            let loginDirty = credentials[1].drop(while: {$0 != ":"})
                            login = String(loginDirty.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
                
                SFSafariApplication.getActiveWindow { (window) in
                    window!.getActiveTab { (activeTab) in
                        activeTab!.getActivePage { (activePage) in
                            activePage!.dispatchMessageToScript(withName: "credentials", userInfo: ["password": password, "login": login, "shortcut": "true", "message": message])
                        }
                    }
                }
            }
        }
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { (activeTab) in
            activeTab!.getActivePage { (activePage) in
                activePage!.getPropertiesWithCompletionHandler { (pageProperties) in
                    // search password, if the toolbar item was clicked
                    let urlHost = pageProperties!.url?.host
                    
                    var urlHostComponents = urlHost!.split(separator: ".")
                    if urlHostComponents.first == "www" {
                        urlHostComponents.removeFirst()
                    }
                    let url = urlHostComponents.joined(separator: ".")
                    
                    let popoverViewController = SafariExtensionViewController.shared
                    let searchField = popoverViewController.searchField
                    DispatchQueue.main.async {
                        searchField!.window?.makeFirstResponder(nil)
                        searchField!.stringValue = url
                        popoverViewController.searchPassword(searchField!)
                        popoverViewController.showSearchResults()
                    }
                }
            }
        }
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        SafariExtensionViewController.shared.resetPopover()
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
