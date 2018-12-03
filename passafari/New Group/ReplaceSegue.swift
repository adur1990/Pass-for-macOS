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
        let destinationViewController = self.destinationController as! NSViewController
        let window = NSApp.windows.filter { (window) -> Bool in
            return window.isSheet
        }[0]
        
        window.contentViewController = destinationViewController
    }
}
