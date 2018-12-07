//
//  FirstRunWindow.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class FirstRunWindow: NSWindow {
    
    // When the app is executed for the first time, we need a sheet window.
    // But sheets cat not become key windows by default, so we need this tiny custom NSWindow class.
    override var canBecomeKey: Bool {
        return true
    }

}
