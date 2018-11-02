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
    func getPathFromBookmark() -> URL? {
        if let data = UserDefaults.standard.data(forKey: "passPathBookmark") {
            var bookmarkDataIsStale: ObjCBool = false
            
            let url = try! (NSURL(resolvingBookmarkData: data, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) as URL)
            if bookmarkDataIsStale.boolValue {
                print("WARNING stale security bookmark")
                return nil
            }
            return url
        }
        return nil
    }
    
    func savePathToBookmark(url: URL) {
        let data = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: "passPathBookmark")
    }
}
