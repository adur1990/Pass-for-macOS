//
//  FirstRunViewController.swift
//  passafari
//
//  Created by Artur Sterz on 28.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class FirstRunViewController: NSViewController {
    @IBOutlet weak var nextButton: NSButton!
    
    
    @IBAction func dismissWindow(_ sender: NSButton) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
}
