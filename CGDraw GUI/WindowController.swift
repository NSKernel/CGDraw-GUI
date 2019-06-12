//
//  WindowController.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/04.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    
    let popoverNewCanvas = NSPopover()
    let popoverSelectColor = NSPopover()
    let popoverBarController = NSPopover()
    let executor = Executor()
    @IBOutlet var drawLineMenu: NSMenu!
    @IBOutlet var drawPolygonMenu: NSMenu!
    @IBOutlet var drawCurveMenu: NSMenu!
    @IBOutlet var clipMenu: NSMenu!
    
    @IBOutlet weak var runButton: NSButton!
    @IBOutlet weak var actionToolBar: NSSegmentedControl!
    @IBOutlet weak var actionToolBarCell: NSSegmentedCell!
    @IBOutlet weak var drawObjectToolBarCell: NSSegmentedCell!
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var drawObjectToolBar: NSSegmentedControl!
    
    @IBOutlet weak var bresenhamButton: NSMenuItem!
    @IBOutlet weak var ddaButton: NSMenuItem!
    @IBOutlet weak var polygonBresenhamButton: NSMenuItem!
    @IBOutlet weak var polygonDDAButton: NSMenuItem!
    @IBOutlet weak var bezierButton: NSMenuItem!
    @IBOutlet weak var bsplineButton: NSMenuItem!
    @IBOutlet weak var csButton: NSMenuItem!
    @IBOutlet weak var lbButton: NSMenuItem!
    
    var globalColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 100)
    
    var drawObjectSelectIndex : Int = -1
    var actionSelectIndex : Int = -1
    var selectedObjectID : Int = -1
    
    var lineAlgorithm : Int = 0
    var polygonAlgorithm : Int = 0
    var curveAlgorithm : Int = 0
    var clipAlgorithm : Int = 0
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let dialog = NewCanvasDialog.freshController()
        dialog.setWindowController(windowController: self)
        let panel = SelectColorPanel.freshController()
        panel.setWindowController(windowController: self)
        let bar = BarViewController.freshController()
        bar.windowController = self
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let codeController = contentVC.splitViewItems[0].viewController as? ViewController
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            let tableVC = rightController.splitViewItems[1].viewController as! ObjectViewController
            let imageView = imageVC.imageView
            imageView!.codeViewController = codeController!.codeView
            imageView!.windowController = self
            tableVC.windowController = self
            tableVC.codeView = codeController!.codeView
            tableVC.objectTable.windowController = self
            codeController?.windowController = self
            bar.codeView = codeController?.codeView
            bar.paintableImageView = imageView
        }
        popoverNewCanvas.contentViewController = dialog
        popoverSelectColor.contentViewController = panel
        popoverBarController.contentViewController = bar
        
        // set drop down menu
        drawObjectToolBar.setMenu(drawLineMenu, forSegment: 0)
        drawObjectToolBar.setMenu(drawPolygonMenu, forSegment: 1)
        drawObjectToolBar.setMenu(drawCurveMenu, forSegment: 3)
        //drawObjectToolBar.setShowsMenuIndicator(true, forSegment: 0)
        
        actionToolBar.setMenu(clipMenu, forSegment: 2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        /** NSWindows loaded from the storyboard will be cascaded
         based on the original frame of the window in the storyboard.
         */
        shouldCascadeWindows = true
    }
    
    func clearDrawObjectSelection() {
        // clear each selection
        drawObjectSelectIndex = -1
        for i in 0 ... 3 {
            drawObjectToolBar.setSelected(false, forSegment: i)
        }
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            let imageView = imageVC.imageView
            imageView!.cleanUp()
        }
    }
    
    func clearActionSelection() {
        actionSelectIndex = -1
        for i in 0 ... 5 {
            actionToolBar.setSelected(false, forSegment: i)
        }
        closePopoverNewCanvas(sender: nil)
        closePopoverSelectColor(sender: nil)
        closePopoverBarController(sender: nil)
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            let imageView = imageVC.imageView
            imageView!.cleanUp()
        }
    }
    
    @IBAction func drawObjectClicked(_ sender: Any) {
        let segmentedControl = sender as! NSSegmentedControl
        let indexClicked = segmentedControl.selectedSegment
        clearActionSelection()
        
        if (indexClicked == drawObjectSelectIndex) {
            // clean up selection
            // clean up image view's draw mode
            segmentedControl.setSelected(false, forSegment: indexClicked)
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let imageView = imageVC.imageView
                imageView!.cleanUp()
            }
            drawObjectSelectIndex = -1
        }
        else {
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let imageView = imageVC.imageView
                drawObjectSelectIndex = indexClicked
                // clean up first
                imageView!.cleanUp()
                if (indexClicked == 0) {
                    // draw line
                    imageView!.drawMode = 1
                }
                if (indexClicked == 1) {
                    // draw polygon
                    imageView!.drawMode = 2
                }
                if (indexClicked == 2) {
                    // draw ellipse
                    imageView!.drawMode = 4
                }
                if (indexClicked == 3) {
                    // draw curve
                    imageView!.drawMode = 3
                }
            }
        }
        
    }
    
    
    @IBAction func actionClicked(_ sender: Any) {
        let segmentedControl = sender as! NSSegmentedControl
        let indexClicked = segmentedControl.selectedSegment
        clearDrawObjectSelection()
        
        if (indexClicked == actionSelectIndex) {
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (popoverBarController.isShown) {
                closePopoverBarController(sender: sender)
            }
            
            actionToolBar.setSelected(false, forSegment: indexClicked)
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let imageView = imageVC.imageView
                imageView!.cleanUp()
            }
            actionSelectIndex = -1
            return
        }
        
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            let imageView = imageVC.imageView
            imageView!.cleanUp()
        }
        
        // newCanvas
        if (indexClicked == 5) {
            // open up popover
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (popoverBarController.isShown) {
                closePopoverBarController(sender: sender)
            }
            if (actionSelectIndex == 5) {
                closePopoverNewCanvas(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 5)
                return
            }
            actionSelectIndex = 5
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            else {
                showPopoverNewCanvas(sender: sender)
            }
        }
        
        // selectColor
        if (indexClicked == 4) {
            // open up popover
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverBarController.isShown) {
                closePopoverBarController(sender: sender)
            }
            if (actionSelectIndex == 4) {
                closePopoverSelectColor(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 4)
                return
            }
            actionSelectIndex = 4
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            else {
                showPopoverSelectColor(sender: sender)
            }
        }
        
        if (indexClicked == 0) {
            // open up popover
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (actionSelectIndex == 0) {
                closePopoverBarController(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 0)
                return
            }
            actionSelectIndex = 0
            if (popoverBarController.isShown) {
                let bar = popoverBarController.contentViewController as! BarViewController
                let mode = bar.mode
                closePopoverBarController(sender: sender)
                bar.slider.maxValue = 2
                bar.slider.minValue = 0
                bar.slider.intValue = 1
                bar.valueLabel.stringValue = "1.0"
                if (mode == 2) {
                    if let contentVC = self.contentViewController as? NSSplitViewController {
                        let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                        let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                        let imageView = imageVC.imageView
                        imageView!.drawMode = 5
                        imageView!.initCenter()
                    }
                    bar.selectedID = selectedObjectID
                    showPopoverBarController(sender: sender, pos: 0)
                }
            }
            else {
                let bar = popoverBarController.contentViewController as! BarViewController
                if (bar.didLoad == false) {
                    bar.maxVal = 2
                    bar.minVal = 0
                    bar.setValue = 1
                    bar.setLabelValue = "1.0"
                }
                else {
                    bar.slider.maxValue = 2
                    bar.slider.minValue = 0
                    bar.slider.intValue = 1
                    bar.valueLabel.stringValue = "1.0"
                }
                if let contentVC = self.contentViewController as? NSSplitViewController {
                    let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                    let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                    let imageView = imageVC.imageView
                    imageView!.drawMode = 5
                    imageView!.initCenter()
                }
                bar.selectedID = selectedObjectID
                showPopoverBarController(sender: sender, pos: 0)
            }
        }
        if (indexClicked == 1) {
            // open up popover
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (actionSelectIndex == 1) {
                closePopoverBarController(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 1)
                return
            }
            actionSelectIndex = 1
            if (popoverBarController.isShown) {
                let bar = popoverBarController.contentViewController as! BarViewController
                let mode = bar.mode
                closePopoverBarController(sender: sender)
                bar.slider.maxValue = 359
                bar.slider.minValue = 0
                bar.slider.intValue = 0
                bar.valueLabel.stringValue = "0"
                if (mode == 1) {
                    if let contentVC = self.contentViewController as? NSSplitViewController {
                        let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                        let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                        let imageView = imageVC.imageView
                        imageView!.drawMode = 5
                        imageView!.initCenter()
                    }
                    bar.selectedID = selectedObjectID
                    showPopoverBarController(sender: sender, pos: 1)
                }
            }
            else {
                let bar = popoverBarController.contentViewController as! BarViewController
                if (bar.didLoad == false) {
                    bar.maxVal = 359
                    bar.minVal = 0
                    bar.setValue = 0
                    bar.setLabelValue = "0"
                }
                else {
                    bar.slider.maxValue = 359
                    bar.slider.minValue = 0
                    bar.slider.intValue = 0
                    bar.valueLabel.stringValue = "0"
                }
                if let contentVC = self.contentViewController as? NSSplitViewController {
                    let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                    let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                    let imageView = imageVC.imageView
                    imageView!.drawMode = 5
                    imageView!.initCenter()
                }
                bar.selectedID = selectedObjectID
                showPopoverBarController(sender: sender, pos: 1)
            }
        }
        if (indexClicked == 2) {
            // clip
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (popoverBarController.isShown) {
                closePopoverBarController(sender: sender)
            }
            if (actionSelectIndex == 2) {
                closePopoverBarController(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 2)
                return
            }
            actionSelectIndex = 2
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let imageView = imageVC.imageView
                imageView!.drawMode = 6
                imageView!.clipID = selectedObjectID
            }
        }
        if (indexClicked == 3) {
            // translate
            if (popoverNewCanvas.isShown) {
                closePopoverNewCanvas(sender: sender)
            }
            if (popoverSelectColor.isShown) {
                closePopoverSelectColor(sender: sender)
            }
            if (popoverBarController.isShown) {
                closePopoverBarController(sender: sender)
            }
            if (actionSelectIndex == 3) {
                closePopoverBarController(sender: sender)
                actionSelectIndex = -1
                actionToolBar.setSelected(false, forSegment: 3)
                return
            }
            actionSelectIndex = 3
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let imageView = imageVC.imageView
                imageView!.drawMode = 7
                imageView!.clipID = selectedObjectID
            }
        }
    }
    
    func showPopoverNewCanvas(sender: Any?) {
        popoverNewCanvas.show(relativeTo: NSMakeRect(actionToolBar.bounds.maxX - 32, actionToolBar.bounds.minY, 32, actionToolBar.bounds.maxY - actionToolBar.bounds.minY), of: actionToolBar, preferredEdge: NSRectEdge.maxY)
        
    }
    
    func closePopoverNewCanvas(sender: Any?) {
        popoverNewCanvas.performClose(sender)
    }
    
    func showPopoverSelectColor(sender: Any?) {
        popoverSelectColor.show(relativeTo: NSMakeRect(actionToolBar.bounds.maxX - 64, actionToolBar.bounds.minY, 32, actionToolBar.bounds.maxY - actionToolBar.bounds.minY), of: actionToolBar, preferredEdge: NSRectEdge.maxY)
        
    }
    
    func closePopoverBarController(sender: Any?) {
        popoverBarController.performClose(sender)
    }
    
    func showPopoverBarController(sender: Any?, pos: Int) {
        let bar = popoverBarController.contentViewController as! BarViewController
        bar.mode = pos + 1
        popoverBarController.show(relativeTo: NSMakeRect((actionToolBar.bounds.minX + CGFloat(32 * pos)), actionToolBar.bounds.minY, 32, actionToolBar.bounds.maxY - actionToolBar.bounds.minY), of: actionToolBar, preferredEdge: NSRectEdge.minY)
    }
    
    func closePopoverSelectColor(sender: Any?) {
        let bar = popoverBarController.contentViewController as! BarViewController
        bar.mode = 0
        popoverSelectColor.performClose(sender)
    }
    
    func requireUpdate() {
        statusTextField.stringValue = "Update is required"
        for i in 0 ... 3 {
            drawObjectToolBar.setSelected(false, forSegment: i)
            drawObjectToolBar.setEnabled(false, forSegment: i)
        }
        drawObjectSelectIndex = -1
        for i in 0 ... 5 {
            actionToolBar.setSelected(false, forSegment: i)
            actionToolBar.setEnabled(false, forSegment: i)
        }
        actionSelectIndex = -1
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            let imageView = imageVC.imageView
            imageView!.cleanUp()
        }
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let codeController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = codeController.splitViewItems[0].viewController as! ImageViewController
            let objectVC = codeController.splitViewItems[1].viewController as! ObjectViewController
            objectVC.clearData()
            imageVC.updateRequiredBackground.isHidden = false
            imageVC.updateRequiredLabel.isHidden = false
        }
    }
    
    func doUpdate() {
        // run and update image view
        var result : ExecuteStatus
        
        // set target location and execute
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let codeController = contentVC.splitViewItems[0].viewController as? ViewController
            if (codeController!.targetLocation.stringValue == "") {
                executor.targetLocation = "~/"
            }
            else {
                executor.targetLocation = codeController!.targetLocation.stringValue
            }
            result = executor.executeCode(code: codeController!.codeView.string)
            if (result.success == false) {
                // update information and display error
                if let contentVC = self.contentViewController as? NSSplitViewController {
                    let codeController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                    let objectVC = codeController.splitViewItems[1].viewController as! ObjectViewController
                    objectVC.consoleOutput.string = result.outputMessage
                    objectVC.consoleOutput.isHidden = false
                }
                statusTextField.stringValue = "Failed to execute"
                return
            }
            statusTextField.stringValue = "Up to date"
            if let contentVC = self.contentViewController as? NSSplitViewController {
                let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
                let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
                let objectVC = rightController.splitViewItems[1].viewController as! ObjectViewController
                imageVC.imageView.image = result.resultImage
                imageVC.updateRequiredBackground.isHidden = true
                imageVC.updateRequiredLabel.isHidden = true
                imageVC.imageView.maxID = Int(result.maxID)
                imageVC.imageView.cleanUp()
                objectVC.consoleOutput.isHidden = true
                // update object table
                objectVC.setObjectTableData(array: result.objectList!)
                objectVC.updateAction()
            }
            // enable edit
            for i in 0 ... 3 {
                drawObjectToolBar.setSelected(false, forSegment: i)
                drawObjectToolBar.setEnabled(true, forSegment: i)
            }
            
            for i in 4 ... 5 {
                actionToolBar.setSelected(false, forSegment: i)
                actionToolBar.setEnabled(true, forSegment: i)
            }
            closePopoverBarController(sender: nil)
            closePopoverNewCanvas(sender: nil)
            closePopoverSelectColor(sender: nil)
            drawObjectSelectIndex = -1
            actionSelectIndex = -1
        }
    }
    
    func disableActions() {
        closePopoverBarController(sender: nil)
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            imageVC.imageView.cleanUp()
        }
        for i in 0 ... 3 {
            actionToolBar.setSelected(false, forSegment: i)
            actionToolBar.setEnabled(false, forSegment: i)
        }
        if (actionSelectIndex <= 3) {
            actionSelectIndex = -1
        }
    }
    
    func enableActions(enableClip : Bool) {
        closePopoverBarController(sender: nil)
        if let contentVC = self.contentViewController as? NSSplitViewController {
            let rightController = contentVC.splitViewItems[1].viewController as! NSSplitViewController
            let imageVC = rightController.splitViewItems[0].viewController as! ImageViewController
            imageVC.imageView.cleanUp()
        }
        if (actionSelectIndex <= 3) {
            actionSelectIndex = -1
        }
        for i in 0 ... 1  {
            actionToolBar.setSelected(false, forSegment: i)
            actionToolBar.setEnabled(true, forSegment: i)
        }
        actionToolBar.setSelected(false, forSegment: 3)
        actionToolBar.setEnabled(true, forSegment: 3)
        actionToolBar.setSelected(false, forSegment: 2)
        if (enableClip == true) {
            actionToolBar.setEnabled(true, forSegment: 2)
        }
        else {
            actionToolBar.setEnabled(false, forSegment: 2)
        }
    }
    
    @IBAction func clickRun(_ sender: Any) {
        doUpdate()
    }
    
    @IBAction func bresenhamClicked(_ sender: Any) {
        ddaButton.state = NSControl.StateValue.off
        bresenhamButton.state = NSControl.StateValue.on
        lineAlgorithm = 0
    }
    
    @IBAction func ddaClicked(_ sender: Any) {
        ddaButton.state = NSControl.StateValue.on
        bresenhamButton.state = NSControl.StateValue.off
        lineAlgorithm = 1
    }
    
    @IBAction func polygonBresenhamClicked(_ sender: Any) {
        polygonDDAButton.state = NSControl.StateValue.off
        polygonBresenhamButton.state = NSControl.StateValue.on
        polygonAlgorithm = 0
    }
    
    @IBAction func polygonDDAClicked(_ sender: Any) {
        polygonDDAButton.state = NSControl.StateValue.on
        polygonBresenhamButton.state = NSControl.StateValue.off
        polygonAlgorithm = 1
    }
    
    @IBAction func bezierClicked(_ sender: Any) {
        bezierButton.state = NSControl.StateValue.on
        bsplineButton.state = NSControl.StateValue.off
        curveAlgorithm = 0
    }
    
    @IBAction func bsplineClicked(_ sender: Any) {
        bezierButton.state = NSControl.StateValue.off
        bsplineButton.state = NSControl.StateValue.on
        curveAlgorithm = 1
    }
    
    @IBAction func csClicked(_ sender: Any) {
        csButton.state = NSControl.StateValue.on
        lbButton.state = NSControl.StateValue.off
        clipAlgorithm = 0
    }
    
    @IBAction func lbClicked(_ sender: Any) {
        csButton.state = NSControl.StateValue.off
        lbButton.state = NSControl.StateValue.on
        clipAlgorithm = 1
    }
}
