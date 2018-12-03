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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let command = "gpg --export-secret-keys \(firstRunGPGKeyID!) > ~/.gnupg/.passafari-private"
        commandLabel.stringValue = command
    }
    
}
