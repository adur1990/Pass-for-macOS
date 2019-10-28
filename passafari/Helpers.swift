//
//  Helpers.swift
//  passafari
//
//  Created by Artur Sterz on 03.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Cocoa
import os.log

let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Extension")

let storeKey = "pass-path"

var firstRunPassPath: URL?

func shake(_ shakeView: NSView) {
    // Shake the given view.
    // Is used if the given user path do not work or are empty.
    let shake = CABasicAnimation(keyPath: "position")
    let xDelta = CGFloat(10)
    shake.duration = 0.05
    shake.repeatCount = 3
    shake.autoreverses = true
    
    let from_point = CGPoint(x: shakeView.frame.minX - xDelta, y: shakeView.frame.minY)
    let from_value = from_point
    
    let to_point = CGPoint(x: shakeView.frame.minX + xDelta, y: shakeView.frame.minY)
    let to_value = to_point
    
    shake.fromValue = from_value
    shake.toValue = to_value
    shake.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    shakeView.layer!.add(shake, forKey: "position")
}

func promptForPath(titleString: String) -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.canCreateDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.showsHiddenFiles = true
    openPanel.title = "Select path for \(titleString)."
    
    if openPanel.runModal() == NSApplication.ModalResponse.OK && !openPanel.urls.isEmpty {
        return openPanel.url
    }
    return nil
}
