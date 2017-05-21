//
//  GraphView.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/20/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Cocoa
import QuartzCore

class GraphView: NSView
{
  var curPosition: CGFloat = 0
  
  // Hardcoded ranges
  var midY: CGFloat? = nil
  var maxAmplitude = 0.001
  
  
		
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
    
    // Temporarily subscribe for notification from DeviceContext directly. Needs to be changed
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateGraph(_:)),
      name: NSNotification.Name(rawValue: Constants.NOTIFICATION_CHANNEL1_VALUE_CHANGED),
      object: nil)
  }
  
  //MARK: -
  //MARK: Event handlers
  func drawSample(pos: CGFloat, amp: Float)
  {
    let value: CGFloat = CGFloat(Double(amp) / maxAmplitude)
    
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
    DispatchQueue.main.async
    {
      let context = NSGraphicsContext.current()?.cgContext
      
      context?.move(to: from)
      context?.addLine(to: to)
      context?.setStrokeColor(color.cgColor)
      context?.drawPath(using: .fillStroke)
    }
  }
  
  //MARK: -
  //MARK: Event handlers
  @objc
  fileprivate func updateGraph(_ notification: Notification)
  {
    let deviceEvent = Device.getDeviceEvent(notification, UUID: "8DD7625E-5CA0-414E-9F3E-7B4F455DDE28")
    if deviceEvent != nil
    {
      let eventData = deviceEvent!.payload as! DeviceStateChangeEvent
      let value = eventData.value as! Float
      
      drawSample(pos: self.curPosition, amp: value)
      
      self.curPosition = self.curPosition + 1
    }
  }
}
