//
//  DeviceCommandStatusView.swift
//  mooshimeter-osx
//
//  Created by Dev on 3/26/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Cocoa
import QuartzCore

class DeviceCommandStatusView : NSView
{
  @IBOutlet weak var viewIndicator: NSView!
  @IBOutlet weak var lblCommandName: NSTextField!
  @IBOutlet weak var lblValue: NSTextField!
  
  required init(coder: NSCoder)
  {
    super.init(coder: coder)!
   
    
    var topLevelObjects = NSArray()
    var view: NSView? = nil
    let frameworkBundle = Bundle(for: classForCoder)
    if frameworkBundle.loadNibNamed("DeviceCommandStatusView", owner: self, topLevelObjects: &topLevelObjects)
    {
      let views = (topLevelObjects as Array).filter { $0 is NSView }
      if views.count > 0
      {
        view = views[0] as? NSView
      }
    }
    
    if view != nil
    {
      self.addSubview(view!)
    }
  }
  
  func setIndicator(value: Bool)
  {
    Async.main({
      self.cancelIndicatorAnimation()
      self.viewIndicator.isHidden = false
    })
    
    if value == true
    {
      Async.main({
        self.viewIndicator.setBackgroundColor(NSColor.green)
        self.fadeIndicator()
      })
    }
    else
    {
      Async.main({
        self.viewIndicator.setBackgroundColor(NSColor.red)
      })
    }
  }
  
  func hideIndicator()
  {
    Async.main({
      self.cancelIndicatorAnimation()
      self.viewIndicator.isHidden = true
    })
  }
  
  func setCommandName(name: String)
  {
    self.lblCommandName.stringValue = name
  }
  
  func setValue(value: String)
  {
    self.lblValue.stringValue = value
    
    self.setIndicator(value: true)
  }
  
  fileprivate func fadeIndicator()
  {
    let layer = self.viewIndicator.layer
    
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "backgroundColor")
    animation.fromValue = layer?.backgroundColor
    animation.toValue = NSColor.gray.cgColor
    animation.duration = 3.0;
    animation.autoreverses = false;
    
    CATransaction.setCompletionBlock
    {
      layer?.backgroundColor = NSColor.red.cgColor
    }
    
    layer?.add(animation, forKey: "backgroundColor")
    CATransaction.commit()
  }
  
  fileprivate func cancelIndicatorAnimation()
  {
    let layer = self.viewIndicator.layer
    layer?.removeAllAnimations()
  }
}
