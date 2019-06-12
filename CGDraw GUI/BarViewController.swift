//
//  BarViewController.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/08.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa

class BarViewController : NSViewController {
    var codeView : LineNumberTextView?
    var windowController : WindowController?
    var paintableImageView : PaintableImageView?
    var selectedID : Int?
    
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var set: NSButton!
    @IBOutlet weak var valueLabel: NSTextField!
    
    // mode
    // 0 : none
    // 1 : scale
    // 2 : rotate
    var mode : Int = 0
    
    var didLoad : Bool = false
    var maxVal : Double = 2.0
    var minVal : Double = 0
    var setValue : Int32 = 1
    var setLabelValue : String = "1.0"
    
    func setBarValue(val: Int) {
        slider.intValue = Int32(val)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        slider.maxValue = maxVal
        slider.minValue = minVal
        slider.intValue = setValue
        valueLabel.stringValue = setLabelValue
        didLoad = true
        
    }
    
    @IBAction func setClicked(_ sender: Any) {
        var insertString : String = ""
        var center = paintableImageView!.translatePointToCanvas(point: paintableImageView!.center!)
        if (mode == 1) {
            insertString += "scale "
        }
        if (mode == 2) {
            insertString += "rotate "
        }
        insertString += String(selectedID!)
        insertString += " " + String(center[0]) + " " + String(center[1]) + " "
        if (mode == 1) {
            insertString += String(format: "%.1f", slider.doubleValue)
        }
        if (mode == 2) {
            insertString += String(slider.intValue)
        }
        codeView?.addText(str: insertString)
        paintableImageView?.cleanUp()
        windowController!.doUpdate()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let sliderReal = sender as! NSSlider
        if (mode == 1) {
            let currentValue = sliderReal.doubleValue
            valueLabel.stringValue = String(format: "%.1f", currentValue)
        }
        if (mode == 2) {
            let currentValue = sliderReal.intValue
            valueLabel.stringValue = String(currentValue)
        }
    }
}

extension BarViewController {
    static func freshController() -> BarViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("BarController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? BarViewController else {
            fatalError("BAR CONTROLLER DIALOG NOT FOUND. Check Main.storyboard")
        }
        return viewcontroller
    }
}
