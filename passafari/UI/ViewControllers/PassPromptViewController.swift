//
//  PassPromptViewController.swift
//  passafari
//
//  Created by Artur Sterz on 05.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class PassPromptViewController: NSViewController {
    @IBOutlet weak var passphraseField: NSSecureTextField!
    
    @IBAction func okButton(_ sender: Any) {
        tmpPassphrase = passphraseField.stringValue
        NSApp.stopModal(withCode: NSApplication.ModalResponse.OK)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        tmpPassphrase = ""
        NSApp.stopModal(withCode: NSApplication.ModalResponse.cancel)
    }
}
