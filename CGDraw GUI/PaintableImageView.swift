//
//  PaintableImageView.swift
//  CGDraw GUI
//
//  Created by Zhao Shixuan on 2019/06/07.
//  Copyright © 2019 NSKernel. All rights reserved.
//

import Foundation
import Cocoa

class Line {
    var start : CGPoint
    var end : CGPoint
    init(start _start : CGPoint, end _end : CGPoint) {
        start = _start
        end = _end
    }
}

class PaintableImageView : NSImageView {
    var codeViewController : LineNumberTextView? = nil
    var windowController : WindowController? = nil
    var tempLine : Line? = nil
    var tempEllipse : Line? = nil
    var center : NSPoint? = nil
    var tempClip : Line? = nil
    var maxID : Int = 0
    var clipID : Int = -1
    var translateArrowBody : Line? = nil
    
    func getScale() -> Float {
        var scaleX : Float = Float(self.image!.size.width) / Float(self.frame.size.width)
        var scaleY : Float = Float(self.image!.size.height) / Float(self.frame.size.height)
        if (scaleX < 1) {
            scaleX = 1
        }
        if (scaleY < 1) {
            scaleY = 1
        }
        if (scaleX > scaleY) {
            return scaleX
        }
        else {
            return scaleY
        }
    }
    
    // 0 : not drawing
    // 1 : draw line
    // 2 : draw polygon
    // 3 : draw curve
    // 4 : draw ellipse
    // 5 : set center
    // 6 : set clip
    // 7 : set translate
    var drawMode : Int = 2
    var firstPointSet : Bool = false
    
    required init?(coder  aDecoder : NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var line : Array<Line> = []
    var lastPt : CGPoint!
    
    func drawArrow(body: Line) {
        let arrowAngle = CGFloat(Double.pi / 5)
        let pointerLineLength = CGFloat(5)
        let startEndAngle = atan((body.end.y - body.start.y) / (body.end.x - body.start.x)) + ((body.end.x - body.start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: body.end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: body.end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: body.end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: body.end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
        
        let arrowDraw = NSBezierPath()
        NSColor.black.setStroke()
        arrowDraw.move(to: NSMakePoint(body.start.x, body.start.y)) // start point
        arrowDraw.line(to: NSMakePoint(body.end.x, body.end.y)) // destination
        arrowDraw.lineWidth = 1  // hair line
        arrowDraw.stroke()  // draw line(s) in color
        arrowDraw.move(to: NSMakePoint(body.end.x, body.end.y)) // start point
        arrowDraw.line(to: NSMakePoint(arrowLine1.x, arrowLine1.y)) // destination
        arrowDraw.lineWidth = 1  // hair line
        arrowDraw.stroke()  // draw line(s) in color
        arrowDraw.move(to: NSMakePoint(body.end.x, body.end.y)) // start point
        arrowDraw.line(to: NSMakePoint(arrowLine2.x, arrowLine2.y)) // destination
        arrowDraw.lineWidth = 1  // hair line
        arrowDraw.stroke()  // draw line(s) in color

    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if (drawMode == 1) {
            let location = self.convert(event.locationInWindow, from: nil)
            lastPt = location
            tempLine = Line(start: location, end: location)
        }
        if (drawMode == 2 || drawMode == 3) {
            let location = self.convert(event.locationInWindow, from: nil)
            if (firstPointSet == true) {
                line.append(Line(start: lastPt, end: location))
            }
            firstPointSet = true
            lastPt = location
            tempLine = Line(start: location, end: location)
            needsDisplay = true
        }
        if (drawMode == 4) {
            let location = self.convert(event.locationInWindow, from: nil)
            lastPt = location
            tempEllipse = Line(start: location, end: location)
        }
        if (drawMode == 5) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            center = newPt
            needsDisplay = true
        }
        if (drawMode == 6) {
            let location = self.convert(event.locationInWindow, from: nil)
            lastPt = location
            tempClip = Line(start: location, end: location)
        }
        if (drawMode == 7) {
            let location = self.convert(event.locationInWindow, from: nil)
            lastPt = location
            translateArrowBody = Line(start: location, end: location)
            
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if (drawMode == 1) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            tempLine!.end = newPt
            needsDisplay = true
        }
        if (drawMode == 4) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            tempEllipse!.end = newPt
            needsDisplay = true
        }
        if (drawMode == 5) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            center = newPt
            needsDisplay = true
        }
        if (drawMode == 6) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            tempClip!.end = newPt
            needsDisplay = true
        }
        if (drawMode == 7) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            translateArrowBody!.end = newPt
            needsDisplay = true
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        if (drawMode == 2 || drawMode == 3) {
            if (firstPointSet == true) {
                let newPt = self.convert(event.locationInWindow, from: nil)
                tempLine!.end = newPt
                needsDisplay = true
            }
        }
    }
    
    var trackingArea : NSTrackingArea?
    
    override func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        let options : NSTrackingArea.Options =
            [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                      owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        if (drawMode == 2) {
            if (firstPointSet == true) {
                // write code
                var insertString = "drawPolygon "
                insertString += String(Int(maxID + 1))
                insertString += " "
                insertString += String(line.count + 1)
                if (windowController!.polygonAlgorithm == 0) {
                    insertString += " Bresenham"
                }
                if (windowController!.polygonAlgorithm == 1) {
                    insertString += " DDA"
                }
                for l in line {
                    let startPos = translatePointToCanvas(point: l.start)
                    insertString += " " + String(startPos[0]) + " " + String(startPos[1])
                }
                let endPos = translatePointToCanvas(point: lastPt)
                insertString += " " + String(endPos[0]) + " " + String(endPos[1])
                codeViewController?.addText(str: insertString)
            }
            cleanUp()
            windowController!.doUpdate()
        }
        if (drawMode == 3) {
            if (firstPointSet == true) {
                // write code
                var insertString = "drawCurve "
                insertString += String(Int(maxID + 1))
                insertString += " "
                insertString += String(line.count + 1)
                if (windowController!.curveAlgorithm == 0) {
                    insertString += " Bezier"
                }
                if (windowController!.curveAlgorithm == 1) {
                    insertString += " B-spline"
                }
                for l in line {
                    let startPos = translatePointToCanvas(point: l.start)
                    insertString += " " + String(startPos[0]) + " " + String(startPos[1])
                }
                let endPos = translatePointToCanvas(point: lastPt)
                insertString += " " + String(endPos[0]) + " " + String(endPos[1])
                codeViewController?.addText(str: insertString)
            }
            cleanUp()
            windowController!.doUpdate()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        if (drawMode == 1) {
            // clear line, insert code, update
            let newPt = self.convert(event.locationInWindow, from: nil)
            let startPos = translatePointToCanvas(point: lastPt)
            let endPos = translatePointToCanvas(point: newPt)
            var insertString = "drawLine " + String(Int(maxID + 1)) + " " + String(startPos[0]) + " " + String(startPos[1]) + " " + String(endPos[0]) + " " + String(endPos[1])
            if (windowController!.lineAlgorithm == 0) {
                insertString += " Bresenham"
            }
            if (windowController!.lineAlgorithm == 1) {
                insertString += " DDA"
            }
            codeViewController!.addText(str: insertString)
            cleanUp()
            windowController!.doUpdate()
        }
        if (drawMode == 4) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            let cent = translatePointToCanvas(point: NSPoint(x: (lastPt.x + newPt.x) / 2, y: (lastPt.y + newPt.y) / 2))
            let rx = abs(Float(lastPt.x - newPt.x)) * getScale() / 2
            let ry = abs(Float(lastPt.y - newPt.y)) * getScale() / 2
            
            codeViewController!.addText(str: "drawEllipse " + String(Int(maxID + 1)) + " " + String(cent[0]) + " " + String(cent[1]) + " " + String(Int(rx)) + " " + String(Int(ry)))
            cleanUp()
            windowController!.doUpdate()
        }
        if (drawMode == 6) {
            let newPt = self.convert(event.locationInWindow, from: nil)
            let startPos = translatePointToCanvas(point: lastPt)
            let endPos = translatePointToCanvas(point: newPt)
            var insertString = "clip " + String(clipID) + " " + String(startPos[0]) + " " + String(startPos[1]) + " " + String(endPos[0]) + " " + String(endPos[1])
            if (windowController!.clipAlgorithm == 0) {
                insertString += " Cohen-Sutherland"
            }
            if (windowController!.clipAlgorithm == 1) {
                insertString += " Liang-Barsky"
            }
            codeViewController!.addText(str: insertString)
            cleanUp()
            windowController!.doUpdate()
        }
        if (drawMode == 7) {
            // clear line, insert code, update
            let newPt = self.convert(event.locationInWindow, from: nil)
            let startPos = translatePointToCanvas(point: lastPt)
            let endPos = translatePointToCanvas(point: newPt)
            let insertString = "translate " + String(clipID) + " " + String(endPos[0] - startPos[0]) + " " + String(endPos[1] - startPos[1])
            codeViewController!.addText(str: insertString)
            cleanUp()
            windowController!.doUpdate()
        }
        // polygon will be set on mouse down
        // not up
        // if (drawMode == 2)
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let figure = NSBezierPath() // container for line(s)
        NSColor.black.setStroke()
        NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.2).setFill()
        if (tempClip != nil) {
            var minX = tempClip!.start.x
            var minY = tempClip!.start.y
            var maxX = tempClip!.start.x
            var maxY = tempClip!.start.y
            if (tempClip!.end.x < minX) {
                minX = tempClip!.end.x
            }
            if (tempClip!.end.y < minY) {
                minY = tempClip!.end.y
            }
            if (tempClip!.end.x > maxX) {
                maxX = tempClip!.end.x
            }
            if (tempClip!.end.y > maxY) {
                maxY = tempClip!.end.y
            }
            let clipWindow = NSBezierPath(rect: CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))
            
            clipWindow.lineWidth = 1
            clipWindow.stroke()
            clipWindow.fill()
        }
        if (translateArrowBody != nil) {
            drawArrow(body: translateArrowBody!)
        }
        if (center != nil) {
            let centerCircle = NSBezierPath(rect: CGRect(x: center!.x - 2, y: center!.y - 2, width: 4, height: 4))
            centerCircle.lineWidth = 1
            centerCircle.stroke()
        }
        windowController!.globalColor.setStroke()
        if (tempLine != nil) {
            figure.move(to: NSMakePoint(tempLine!.start.x, tempLine!.start.y)) // start point
            figure.line(to: NSMakePoint(tempLine!.end.x, tempLine!.end.y)) // destination
            figure.lineWidth = 1  // hair line
            figure.stroke()  // draw line(s) in color
        }
        if (tempEllipse != nil) {
            var minX = tempEllipse!.start.x
            var minY = tempEllipse!.start.y
            var maxX = tempEllipse!.start.x
            var maxY = tempEllipse!.start.y
            if (tempEllipse!.end.x < minX) {
                minX = tempEllipse!.end.x
            }
            if (tempEllipse!.end.y < minY) {
                minY = tempEllipse!.end.y
            }
            if (tempEllipse!.end.x > maxX) {
                maxX = tempEllipse!.end.x
            }
            if (tempEllipse!.end.y > maxY) {
                maxY = tempEllipse!.end.y
            }
            let ellipse = NSBezierPath(ovalIn: CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))
            ellipse.lineWidth = 1  // hair line
            ellipse.stroke()  // draw line(s) in color
            
        }
        
        for l in line {
            figure.move(to: NSMakePoint(l.start.x, l.start.y)) // start point
            figure.line(to: NSMakePoint(l.end.x, l.end.y)) // destination
            figure.lineWidth = 1  // hair line
            figure.stroke()  // draw line(s) in color
        }
        
    }
    
    func translatePointToCanvas(point : NSPoint) -> [Int] {
        let scale = getScale()
        let viewMidPointX = self.frame.size.width / 2
        let viewMidPointY = self.frame.size.height / 2
        let deltaX = Float(point.x - viewMidPointX) * scale
        let deltaY = Float(point.y - viewMidPointY) * scale
        let posX = deltaX + Float(self.image!.size.width) / 2
        let posY = deltaY + Float(self.image!.size.height) / 2
        return [Int(posX), Int(posY)]
    }
 
    func cleanUp() {
        drawMode = 0
        firstPointSet = false
        tempLine = nil
        tempEllipse = nil
        center = nil
        tempClip = nil
        line = []
        translateArrowBody = nil
        needsDisplay = true
    }
    
    func initCenter() {
        center = NSPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
    }
    
    func clearCenter() {
        center = nil
    }
}
