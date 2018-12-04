//
//  AppearenceViewController.swift
//  passafari
//
//  Created by Artur Sterz on 04.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class DoneViewController: NSViewController {
    @IBOutlet weak var doneButton: NSButton!
    
    @IBAction func setupDone(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.OK)
    }
    
    @IBAction func segueToPassphrase(_ sender: Any) {
        performSegue(withIdentifier: "segueBackToPassphrase", sender: self.view.window)
}
    
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
    override func viewDidAppear() {
        if doneButton.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(doneButton)
        }
    }
    
}
