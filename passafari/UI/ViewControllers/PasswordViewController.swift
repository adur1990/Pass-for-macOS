//
//  PasswordViewController.swift
//  passafari
//
//  Created by Artur Sterz on 04.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa
import os.log

import ObjectivePGP

class PasswordViewController: NSViewController {
    @IBOutlet weak var nextViewButton: NSButton!
    @IBOutlet weak var passphraseField: NSSecureTextField!
    
    @IBAction func segueToAppearenceView(_ sender: Any) {
        if !passphraseField.stringValue.isEmpty {
            // In this case, the user wants the passphrase to be stored in the keychain.
            firstRunPassphrase = passphraseField.stringValue
            
            // Check, if the given passphrase is correct.
            
            let tmp_keyring = Keyring()
            if firstRunKeyPath!.startAccessingSecurityScopedResource() {
                tmp_keyring.import(keys: try! ObjectivePGP.readKeys(fromPath: firstRunKeyPath!.appendingPathComponent(privKeyFilename).path))
            }
            firstRunKeyPath!.stopAccessingSecurityScopedResource()
            
            let dataToSign = "TestString".data(using: .utf8)
            do {
                try ObjectivePGP.sign(dataToSign!, detached: true, using: tmp_keyring.keys) { (key) -> String? in
                    return firstRunPassphrase
                }
            } catch {
                shake(passphraseField)
                os_log(.error, log: logger, "%s", "Can sign due to error: \(error).")
                return
            }
            
            do{
                try storePassphrase(passphrase: passphraseField.stringValue)
            } catch {
                os_log(.error, log: logger, "%s", "Can not store passphrase with reason \(error).")
            }
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
        // This is used for filling the textfield, if the user comes back after already going to the next view
        if (firstRunPassphrase != nil) {
            passphraseField.stringValue = firstRunPassphrase!
        }
    }
}
