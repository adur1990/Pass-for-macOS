//
//  FirstRunViewController.swift
//  passafari
//
//  Created by Artur Sterz on 28.11.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class IntroViewController: NSViewController {
    @IBOutlet weak var nextViewButton: NSButton!
    
    
    @IBAction func performSegueToPassPathSelection(_ sender: Any) {
        performSegue(withIdentifier: "segueToPassPath", sender: self.view.window)
    }
    
    @IBAction func dismissWindow(_ sender: NSButton) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
    override func viewDidAppear() {
        if nextViewButton.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(nextViewButton)
        }
    }
}
