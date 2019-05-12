//
//  GraphView.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/20/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Foundation
import AppKit
import QuartzCore

class GraphView: NSView
{
  var curPosition: Int = 0
  let sampleContainer = MeasurementsContainer(MeasurementType.voltage)
  var layers = [CALayer]()
  
  // Hardcoded ranges
  var midY: CGFloat? = nil
  var maxAmplitude = 0.001
  var sampleStep: Int = 5
  
  required init?(coder: NSCoder)
  {
    super.init(coder: coder)
    
    initialize()
  }
  
  override init(frame frameRect: NSRect)
  {
    super.init(frame: frameRect)
    
    initialize()
  }

  func initialize()
  {
    self.wantsLayer = true // Layer is not automatically allocated anymore
    self.layer?.backgroundColor = NSColor.black.cgColor
    
    self.midY = self.frame.height / 2
    self.createSublayers()
    
    // Temporarily subscribe for notification from DeviceContext directly. Needs to be changed
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateGraph(_:)),
      name: NSNotification.Name(rawValue: Constants.NOTIFICATION_CHANNEL1_VALUE_CHANGED),
      object: nil)
  }
  
  func createSublayers()
  {
    let baseX = self.frame.origin.x
    let y: CGFloat = 0
    let width: CGFloat = 50
    let height: CGFloat = 400
    
    let baseColor = NSColor(deviceHue:0.8, saturation:0.0, lightness:0.5, alpha:0.5)
    
    
    for i in 0...19
    {
      let x = baseX + CGFloat(i) * width
      let frame = CGRect(x: x, y: y, width: width, height: height)
      let color = NSColor(deviceHue: baseColor.hueComponent, saturation: baseColor.hueComponent, lightness: baseColor.lightnessComponent + CGFloat(i) * CGFloat(0.025), alpha: baseColor.alphaComponent)
      
      let layer = CALayer()
      layer.frame = frame
      layer.backgroundColor = color.cgColor
      
      self.layer?.addSublayer(layer)
      
      layers.append(layer)
    }
  }
  
  override func draw(_ dirtyRect: NSRect)
  {
    for i in 0...curPosition
    {
      //drawSample(pos: CGFloat(i * self.sampleStep), amp: sampleContainer.samples[i]!)
      drawLineSample(pos: i)
    }
  }
  
  //MARK: -
  //MARK: Helper methods
  func drawLineSample(pos: Int)
  {
    let amp = self.sampleContainer.samples[pos]!
    var prevAmp: Float = 0
    var prevPos = pos
    if pos > 0
    {
      prevPos = pos - 1
    }
    prevAmp = self.sampleContainer.samples[prevPos]!
    
    let x = CGFloat(pos * self.sampleStep)
    let prevX = CGFloat(prevPos * self.sampleStep)
    
    let value: CGFloat = CGFloat(Double(amp) / maxAmplitude * 50)
    let prevValue: CGFloat = CGFloat(Double(prevAmp) / maxAmplitude * 50)
    
    let from = CGPoint(x: prevX, y: prevValue + midY!)
    let to = CGPoint(x: x, y: value + midY!)
    let color: NSColor = NSColor.green

    drawLine(from: from, to: to, color: color)
  }
  
  func drawSample(pos: CGFloat, amp: Float)
  {
    let value: CGFloat = CGFloat(Double(amp) / maxAmplitude * 50)
    
    let zero = CGPoint(x: pos, y: midY!)
    let point = CGPoint(x: pos, y: value + midY!)
    var color: NSColor = NSColor.green
    if amp < 0.0
    {
      color = NSColor.yellow
    }
    
    drawLine(from: zero, to: point, color: color)
  }
  
  func drawLine(from: CGPoint, to: CGPoint, color: NSColor)
  {
    let context: CGContext = (NSGraphicsContext.current?.cgContext)!
    
    context.setShouldAntialias(true)
    context.setStrokeColor(color.cgColor)
    context.move(to: from)
    context.addLine(to: to)
    
    context.strokePath()
  }
  
  func scrollLayers(_ offset: Int)
  {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    
    for layer in layers
    {
      var position = layer.position
      position.x = position.x + CGFloat(offset)
      layer.position = position
      layer.needsLayout()
    }
    
    CATransaction.commit()
  }
  
  func resetLayers()
  {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    
    let baseX = self.frame.origin.x
    let y: CGFloat = 0
    let width: CGFloat = 50
    let height: CGFloat = 400
    
    var i = 0
    for layer in layers
    {
      let x = baseX + CGFloat(i) * width
      let frame = CGRect(x: x, y: y, width: width, height: height)
      layer.frame = frame
      layer.needsLayout()
      
      i = i + 1
    }
    
    CATransaction.commit()
  }
  
  //MARK: -
  //MARK: Event handlers
  @objc
  fileprivate func updateGraph(_ notification: Notification)
  {
    let deviceEvent = Device.getDeviceEvent(notification, UUID: "A0F2383A-C35E-44B0-A0B3-492506892785")
    if deviceEvent != nil
    {
      let eventData = deviceEvent!.payload as! DeviceStateChangeEvent
      //let value = eventData.value as! Float
      
      self.curPosition = self.curPosition + sampleStep
      
      if curPosition >= sampleContainer.samples.count
      {
        curPosition = 0
        
        DispatchQueue.main.async
        {
          self.resetLayers()
        }
      }
      else
      {
        DispatchQueue.main.async
          {
            self.scrollLayers(-1 * self.sampleStep)
        }
      }
      
      DispatchQueue.main.async
      {
        self.setNeedsDisplay(self.frame)
        self.needsDisplay = true
      }
    }
  }
}
