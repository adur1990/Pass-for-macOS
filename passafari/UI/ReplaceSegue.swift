//
//  ReplaceSegue.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class ReplaceSegue: NSStoryboardSegue {
    
    override func perform() {
        // Cocoa has no default segue to replace viewcontroller of a window, so we have to build one for ourselfs
        let destinationViewController = self.destinationController as! NSViewController
        let window = NSApp.windows.filter { (window) -> Bool in
            return window.isSheet
        }[0]
        
        window.contentViewController = destinationViewController
    }
}
