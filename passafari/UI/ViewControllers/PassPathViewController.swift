//
//  PassPathViewController.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa
import os.log

class PassPathViewController: NSViewController {
    @IBOutlet weak var nextViewButton: NSButton!
    @IBOutlet weak var passPathTextField: NSTextField!
    
    @IBAction func segueToIntro(_ sender: Any) {
        performSegue(withIdentifier: "segueBackToIntro", sender: self.view.window)
    }
    
    @IBAction func browsePassPath(_ sender: Any) {
        // Ask user for the passwordstore path, remember it using bookmarks and get the key id for the next view.
        if let urlFromPanel = promptForPath(titleString: storeKey) {
            sharedSecureBookmarkHandler.savePathToBookmark(url: urlFromPanel, forKey: storeKey)
            firstRunPassPath = urlFromPanel
            passPathTextField.stringValue = urlFromPanel.path
        }
    }
    
    override func viewDidLoad() {
        // This is used for filling the textfield, if the user comes back after already going to the next view
        if (firstRunPassPath != nil) {
            passPathTextField.stringValue = firstRunPassPath!.path
        }
    }
    
    override func viewDidAppear() {
        if nextViewButton.acceptsFirstResponder {
            self.view.window!.makeFirstResponder(nextViewButton)
        }
    }
    
    @IBAction func setupDone(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.OK)
    }
        
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
}
