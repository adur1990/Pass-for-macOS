//
//  KeyPathViewController.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class KeyPathViewController: NSViewController {
    @IBOutlet weak var commandLabel: NSTextField!
    @IBOutlet weak var nextViewButton: NSButton!
    @IBOutlet weak var keyPathTextField: NSTextField!
    
    @IBAction func segueToPasswordView(_ sender: Any) {
        if keyPathTextField.stringValue.isEmpty {
            shake(keyPathTextField)
        } else {
            if firstRunKeyPath!.startAccessingSecurityScopedResource() {
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: firstRunKeyPath!.appendingPathComponent(privKeyFilename).path) {
                    firstRunKeyPath!.stopAccessingSecurityScopedResource()
                    performSegue(withIdentifier: "segueToPassword", sender: sender)
                } else {
                    shake(keyPathTextField)
                    firstRunKeyPath!.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    @IBAction func segueToPassPath(_ sender: Any) {
        performSegue(withIdentifier: "segueBackToPassPath", sender: self.view.window)
    }
    
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
    @IBAction func browseKeyPath(_ sender: Any) {
        if let urlFromPanel = promptForPath(titleString: gpgKey) {
            firstRunKeyPath = urlFromPanel
            keyPathTextField.stringValue = urlFromPanel.path
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: gpgKey)
        }
    }
    override func viewDidAppear() {
        if nextViewButton.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(nextViewButton)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (firstRunKeyPath != nil) {
            keyPathTextField.stringValue = firstRunKeyPath!.path
        }
        
        let command = "gpg --export-secret-keys \(firstRunGPGKeyID!) > ~/.gnupg/\(privKeyFilename)"
        commandLabel.stringValue = command
    }
    
}
