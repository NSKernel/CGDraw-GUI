//
//  ObjectViewController.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/07.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa

class ObjectViewController : NSViewController {
    var codeView : LineNumberTextView?
    var windowController : WindowController?
    
    
    @IBOutlet var consoleOutput: NSTextView!
    @IBOutlet weak var objectTable: AutoDeselectTableView!
    
    var objectTableData : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        consoleOutput.font = NSFont(name: "SF Mono", size: 14)
        objectTable.dataSource = self
    }
    
    func setObjectTableData(array : [CGDrawObject]) {
        objectTableData = []
        for row in array {
            let rowData : NSDictionary = ["ID" : String(row.ID), "Type" : ObjectTypeArray[Int(row.objectType)]]
            objectTableData.append(rowData)
        }
        objectTable.reloadData()
    }
    
    
}

extension ObjectViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return objectTableData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return objectTableData[row][(tableColumn?.identifier.rawValue)!]
    }
    
    func clearData() {
        objectTableData = []
        objectTable.reloadData()
    }
}

extension ObjectViewController : NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateAction()
    }
    
    func updateAction() {
        // choose selected row
        let row = objectTable.selectedRow
        if (row != -1) {
            // set selected id
            let typeString = objectTableData[row]["Type"] as! String
            windowController!.selectedObjectID = Int(objectTableData[row]["ID"]  as! String)!
            windowController!.enableActions(enableClip: typeString == "Line")
        }
        else {
            windowController!.selectedObjectID = -1
            windowController!.disableActions()
        }
    }
}
