//
//  Executor.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/06.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa

struct CGDrawObject {
    var ID : UInt32
    var objectType : UInt8
    var xMin : Float
    var xMax : Float
    var yMin : Float
    var yMax : Float
}

let ObjectTypeArray = ["Error", "Line", "Polygon", "Ellipse", "Curve", "Ellipse", "Error"]

// error:
//    0 : Unexpected
//    1 : Cannot write temp file
//    2 : Failed in cmmc

struct ExecuteStatus {
    var success : Bool
    var error : UInt8
    var canvasExists : Bool
    var resultImage : NSImage?
    var objectList : [CGDrawObject]?
    var outputMessage : String
    var maxID : UInt32
}

class Executor {
    var targetLocation : String = "~/"
    var maxID : UInt32 = 0
    
    func executeCode(code : String) -> ExecuteStatus {
        //
        //  1. save the code
        //  2. execute
        //  3. load image and csv
        //
        
        // init maxID to 0
        maxID = 0
        
        // 1. save the code
        var codePath : String
        var retStatus : ExecuteStatus = ExecuteStatus(success: false, error: 0, canvasExists: false, resultImage: nil, objectList: nil, outputMessage: "", maxID: 0)
        
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempCodeFilename = ProcessInfo().globallyUniqueString
        let outputFilename = ProcessInfo().globallyUniqueString
        let tempCodeFileURL = tempDirectoryURL.appendingPathComponent(tempCodeFilename)
        let outputFileURL = tempDirectoryURL.appendingPathComponent(outputFilename)
        do {
            try Data(code.utf8).write(to: tempCodeFileURL, options: .atomicWrite)
            codePath = tempCodeFileURL.path
        }
        catch {
            // Failed to write
            retStatus.success = false
            retStatus.error = 1
            retStatus.canvasExists = false
            return retStatus
        }
        
        // 2. execute code
        // get cgdraw path
        let cgdrawPath = Bundle.main.resourcePath! + "/cgdraw"
        
        // chmod 775
        let chmodTask = Process()
        chmodTask.launchPath = "/bin/chmod"
        chmodTask.arguments = ["755", cgdrawPath]
        chmodTask.launch()
        chmodTask.waitUntilExit()
        
        // execute with NSTask
        let task = Process()
        task.launchPath = cgdrawPath
        task.arguments = [codePath, targetLocation, "-g", outputFileURL.path, "-s", "-n"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        retStatus.outputMessage = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        if (task.terminationStatus != 0) {
            // shit happened
            retStatus.success = false
            retStatus.error = 2
            retStatus.canvasExists = false
            return retStatus
        }
        
        // 3. load image and csv
        // load image
        retStatus.resultImage = NSImage(byReferencingFile: outputFileURL.path + ".bmp")
        // load csv
        retStatus.objectList = readCSV(csvPath: outputFileURL.path + ".csv")
        if (retStatus.objectList != nil) {
            retStatus.success = true
        }
        print(retStatus.outputMessage)
        retStatus.maxID = maxID
        return retStatus
    }
    
    func readCSV(csvPath: String) -> [CGDrawObject]? {
        var retList : [CGDrawObject] = []
        do {
            let file = try String(contentsOfFile: csvPath)
            let rows = file.components(separatedBy: .newlines)
            for row in rows {
                let fields = row.replacingOccurrences(of: "\"", with: "").components(separatedBy: ",")
                if (fields.count == 6) {
                    do {
                        let objectTemp : CGDrawObject = CGDrawObject(ID: UInt32(Int(fields[0])!), objectType: UInt8(fields[1])!, xMin: Float(fields[2])!, xMax: Float(fields[3])!, yMin: Float(fields[4])!, yMax: Float(fields[5])!)
                        if (objectTemp.ID > maxID) {
                            maxID = objectTemp.ID
                        }
                        retList.append(objectTemp)
                    }
                    catch {
                        print("WARNING: Wrong in line")
                    }
                }
                else {
                    print("WARNING: Wrong CSV line")
                }
                
            }
            return retList
        }
        catch {
            print(error)
            return nil
        }
    }
}
