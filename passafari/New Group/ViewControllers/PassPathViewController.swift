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
    
    func shake(_ shakeView: NSView) {
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
    
    @IBAction func segueToKeyPathView(_ sender: Any) {
        if passPathTextField.stringValue.isEmpty {
            shake(passPathTextField)
        }
    }
    
    @IBAction func dissmisWindow(_ sender: Any) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: NSApplication.ModalResponse.stop)
    }
    
}
