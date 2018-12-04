//
//  PasswordViewController.swift
//  passafari
//
//  Created by Artur Sterz on 04.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class PasswordViewController: NSViewController {
    @IBOutlet weak var nextViewButton: NSButton!
    @IBOutlet weak var passphraseField: NSSecureTextField!
    
    @IBAction func segueToAppearenceView(_ sender: Any) {
        if !passphraseField.stringValue.isEmpty {
            firstRunPassphrase = passphraseField.stringValue
        }
        performSegue(withIdentifier: "segueToAppearence", sender: sender)
    }
    
    @IBAction func segueToKeyPath(_ sender: Any) {
        performSegue(withIdentifier: "segueBackToKeyPath", sender: self.view.window)
    }
    
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
    override func viewDidAppear() {
        if nextViewButton.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(nextViewButton)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (firstRunPassphrase != nil) {
            passphraseField.stringValue = firstRunPassphrase!
        }
    }
    
}
