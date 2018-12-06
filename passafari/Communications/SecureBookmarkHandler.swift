//
//  SecureBookmarkHandler.swift
//  passafari
//
//  Created by Artur Sterz on 02.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation

let sharedSecureBookmarkHandler = SecureBookmarkHandler()

class SecureBookmarkHandler {
    func getPathFromBookmark(forKey key: String) -> URL? {
        if let data = UserDefaults.standard.data(forKey: key) {
            var bookmarkDataIsStale: ObjCBool = false
            
            let url = try! (NSURL(resolvingBookmarkData: data, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) as URL)
            if bookmarkDataIsStale.boolValue {
                return nil
            }
            return url
        }
        return nil
    }
    
    func savePathToBookmark(url: URL, forKey key: String) {
        let data = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: key)
    }
}
