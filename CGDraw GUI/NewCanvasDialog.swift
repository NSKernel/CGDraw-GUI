//
//  NewCanvasDialog.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/04.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Cocoa

class NewCanvasDialog: NSViewController, NSTextFieldDelegate {
    var windowController : WindowController? = nil

    
    @IBOutlet weak var xSize: NSTextField!
    @IBOutlet weak var ySize: NSTextField!
    @IBOutlet weak var killOld: NSButton!
    
    func setWindowController(windowController: WindowController) {
        self.windowController = windowController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let onlyIntFormatter = OnlyIntegerValueFormatter()
        onlyIntFormatter.minimum = 0
        onlyIntFormatter.maximum = 100000
        xSize.formatter = onlyIntFormatter
        ySize.formatter = onlyIntFormatter
    }
    
    @IBAction func createClick(_ sender: Any) {
        windowController?.closePopoverNewCanvas(sender: sender)
        var insertString = "resetCanvas "
        if (xSize.stringValue != "") {
            insertString += xSize.stringValue
        }
        else {
            insertString += "100"
        }
        insertString += " "
        if (ySize.stringValue != "") {
            insertString += ySize.stringValue
        }
        else {
            insertString += "100"
        }
        if let contentVC = windowController?.contentViewController as? NSSplitViewController {
            let codeController = contentVC.splitViewItems[0].viewController as? ViewController
            if (killOld.state == NSControl.StateValue.on) {
                codeController?.codeView.string = insertString
            }
            else {
                codeController?.codeView.addText(str: insertString)
            }
        }
        windowController!.doUpdate()
    }
    
    func controlTextDidChange(_ notification: Notification) {
        let charSet = NSCharacterSet(charactersIn: "1234567890.").inverted
        let charsX = xSize.stringValue.components(separatedBy: charSet)
        let charsY = ySize.stringValue.components(separatedBy: charSet)
        xSize.stringValue = charsX.joined()
        ySize.stringValue = charsY.joined()
    }
}


extension NewCanvasDialog {
    static func freshController() -> NewCanvasDialog {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("NewCanvasDialog")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NewCanvasDialog else {
            fatalError("NEW CANVAS DIALOG NOT FOUND. Check Main.storyboard")
        }
        return viewcontroller
    }
}
