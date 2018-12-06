//
//  SecureBookmarkHandler.swift
//  passafari
//
//  Created by Artur Sterz on 02.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation
import os.log

let sharedSecureBookmarkHandler = SecureBookmarkHandler()

class SecureBookmarkHandler {
    func getPathFromBookmark(forKey key: String) -> URL? {
        if let data = UserDefaults.standard.data(forKey: key) {
            var bookmarkDataIsStale: ObjCBool = false
            
            let url = try! (NSURL(resolvingBookmarkData: data, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) as URL)
            if bookmarkDataIsStale.boolValue {
                os_log(.error, log: logger, "%s", "Could not get path from bookmark, because bookmark is \(url) stale.")
                return nil
            }
            return url
        }
        os_log(.error, log: logger, "%s", "Key \(key) was not found in bookmark store.")
        return nil
    }
    
    func savePathToBookmark(url: URL, forKey key: String) {
        let data = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: key)
    }
}
