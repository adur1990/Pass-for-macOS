//
//  KeyPathViewController.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa

class KeyPathViewController: NSViewController {
    @IBOutlet weak var commandScrollView: NSScrollView!
    @IBOutlet weak var commandLabel: NSTextView!
    @IBOutlet weak var copyToClipboard: NSButton!
    @IBOutlet weak var nextViewButton: NSButton!
    @IBOutlet weak var keyPathTextField: NSTextField!
    
    @IBAction func segueToPasswordView(_ sender: Any) {
        if keyPathTextField.stringValue.isEmpty {
            // Make sure, the path to the key is set.
            shake(keyPathTextField)
        } else {
            if firstRunKeyPath!.startAccessingSecurityScopedResource() {
                let fileManager = FileManager.default
                // We have to make sure, the private key is in the path the user gave us.
                if fileManager.fileExists(atPath: firstRunKeyPath!.appendingPathComponent(privKeyFilename).path) {
                    firstRunKeyPath!.stopAccessingSecurityScopedResource()
                    performSegue(withIdentifier: "segueToPassword", sender: sender)
                } else {
                    // If the private key is not available, shake.
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
    
    @IBAction func copyToClipboard(_ sender: Any) {
        copyToClipBoard(textToCopy: commandLabel.string)
    }
    
    @IBAction func browseKeyPath(_ sender: Any) {
        // Ask the user, where the private key is, remember this path in bookmarks.
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
        // This is used for filling the textfield, if the user comes back after already going to the next view
        if (firstRunKeyPath != nil) {
            keyPathTextField.stringValue = firstRunKeyPath!.path
        }
        
        let font = NSFont(name: "Menlo", size: 13)
        let attributes = NSDictionary(object: font!, forKey: NSAttributedString.Key.font as NSCopying)
        commandLabel.typingAttributes = attributes as! [NSAttributedString.Key : Any]
        commandLabel.textColor = keyPathTextField.textColor
        
        commandScrollView.hasHorizontalScroller = true
        commandLabel.maxSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        commandLabel.isHorizontallyResizable = true
        commandLabel.textContainer?.widthTracksTextView = false
        commandLabel.textContainer?.containerSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
        
        // We show the user a hint how to export the private key.
        let command = "gpg --export-secret-keys \(firstRunGPGKeyID!) > ~/.gnupg/\(privKeyFilename)"
        commandLabel.string = command
    }
    
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
}
