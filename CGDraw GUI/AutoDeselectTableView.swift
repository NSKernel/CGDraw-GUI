//
//  AutoDeselectTableView.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/07.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa

class AutoDeselectTableView : NSTableView {
    var windowController : WindowController?
    
    override func resignFirstResponder() -> Bool {
        windowController?.disableActions()
        self.deselectAll(nil)
        return true
    }
}
