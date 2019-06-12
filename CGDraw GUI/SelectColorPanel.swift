//
//  SelectColorPanel.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/05.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa



class SelectColorPanel : NSViewController, NSTextFieldDelegate {
    var windowController : WindowController? = nil
    
    @IBOutlet weak var rValue: NSTextField!
    @IBOutlet weak var gValue: NSTextField!
    @IBOutlet weak var bValue: NSTextField!
    @IBOutlet weak var previewView: NSTextField!
    
    func setWindowController(windowController: WindowController) {
        self.windowController = windowController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let onlyIntFormatter = OnlyIntegerValueFormatter()
        rValue.formatter = onlyIntFormatter
        gValue.formatter = onlyIntFormatter
        bValue.formatter = onlyIntFormatter
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if (rValue.stringValue == "") {
            rValue.stringValue = "0"
        }
        if (gValue.stringValue == "") {
            gValue.stringValue = "0"
        }
        if (bValue.stringValue == "") {
            bValue.stringValue = "0"
        }
        if (Int(rValue.stringValue)! > 255) {
            rValue.stringValue = "255"
        }
        if (Int(gValue.stringValue)! > 255) {
            gValue.stringValue = "255"
        }
        if (Int(bValue.stringValue)! > 255) {
            bValue.stringValue = "255"
        }
        let R = Int(rValue.stringValue)!
        let G = Int(gValue.stringValue)!
        let B = Int(bValue.stringValue)!
        previewView.backgroundColor = NSColor(calibratedRed: CGFloat(Double(R) / 255.0), green: CGFloat(Double(G) / 255.0), blue: CGFloat(Double(B) / 255.0), alpha: 100)
    }
    
    @IBAction func setClick(_ sender: Any) {
        windowController?.closePopoverSelectColor(sender: sender)
        windowController?.globalColor = previewView.backgroundColor!
        let insertString = "setColor " + rValue.stringValue + " " + gValue.stringValue + " " + bValue.stringValue
        
        if let contentVC = windowController?.contentViewController as? NSSplitViewController {
            let codeController = contentVC.splitViewItems[0].viewController as? ViewController
            codeController?.codeView.addText(str: insertString)
            
        }
        windowController!.doUpdate()
    }
}

extension SelectColorPanel {
    static func freshController() -> SelectColorPanel {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("SelectColorPanel")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? SelectColorPanel else {
            fatalError("SELECT COLOR PANEL NOT FOUND. Check Main.storyboard")
        }
        return viewcontroller
    }
}
