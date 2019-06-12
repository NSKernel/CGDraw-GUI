//
//  ViewController.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/05/30.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    var windowController : WindowController? = nil

    @IBOutlet var codeView: LineNumberTextView!
    @IBOutlet weak var targetLocation: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        codeView.font = NSFont(name: "SF Mono", size: 14)
        let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
        targetLocation.stringValue = homeDirURL.path
        if (codeView.string != "") {
            windowController!.requireUpdate()
        }
    }

    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }

    weak var document: Document? {
        if let docRepresentedObject = representedObject as? Document {
            return docRepresentedObject
        }
        return nil
    }

    // MARK: - NSTextViewDelegate
    
    func textDidBeginEditing(_ notification: Notification) {
        document?.objectDidBeginEditing(self)
    }
    
    func textDidEndEditing(_ notification: Notification) {
        document?.objectDidEndEditing(self)
    }
    
    func textDidChange(_ notification: Notification) {
        windowController!.requireUpdate()
        if (codeView.string == "") {
            windowController!.runButton.isEnabled = false
            windowController!.statusTextField.stringValue = "Waiting for a new canvas"
            windowController?.actionToolBarCell.setEnabled(true, forSegment: 5)
        }
        else {
            windowController!.runButton.isEnabled = true
            windowController!.statusTextField.stringValue = "Update is required"
            windowController?.actionToolBarCell.setEnabled(false, forSegment: 5)
            
        }
    }
    
}

