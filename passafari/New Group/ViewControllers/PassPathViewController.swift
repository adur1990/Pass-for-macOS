//
//  PassPathViewController.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class PassPathViewController: NSViewController {
    @IBOutlet weak var passPathTextField: NSTextField!
    
    @IBAction func segueToKeyPathView(_ sender: Any) {
        if passPathTextField.stringValue.isEmpty {
            shake(passPathTextField)
        }
    }
    
    @IBAction func segueToIntro(_ sender: Any) {
        performSegue(withIdentifier: "segueBackToIntro", sender: self.view.window)
    }
    
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
    @IBAction func browsePassPath(_ sender: Any) {
        if let urlFromPanel = promptForPath(titleString: storeKey) {
            firstRunPassPath = urlFromPanel
            passPathTextField.stringValue = urlFromPanel.path
            if urlFromPanel.startAccessingSecurityScopedResource() {
                let keyIDUrl = urlFromPanel.appendingPathComponent(".gpg-id")
                do{
                    firstRunGPGKeyID = try String(contentsOf: keyIDUrl, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                } catch {
                    urlFromPanel.stopAccessingSecurityScopedResource()
                    return
                }
                urlFromPanel.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    override func viewDidLoad() {
        if (firstRunPassPath != nil) {
            passPathTextField.stringValue = firstRunPassPath!.path
        }
    }
}
