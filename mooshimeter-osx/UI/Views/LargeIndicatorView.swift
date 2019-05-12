//
//  LargeIndicator.swift
//  mooshimeter-osx
//
//  Created by Dev on 5/24/17.
//  Copyright © 2017 alfishe. All rights reserved.
//

import Cocoa
import QuartzCore

@IBDesignable
class LargeIndicatorView: NSView
{
  @IBOutlet weak var lblMode: NSTextField!
  @IBOutlet weak var lblSign: NSTextField!
  @IBOutlet weak var lblValue: NSTextField!
  
  required init(coder: NSCoder)
  {
    super.init(coder: coder)!
    
    var topLevelObjects: NSArray? = nil
    var view: NSView? = nil
    let frameworkBundle = Bundle(for: classForCoder)
    if frameworkBundle.loadNibNamed("LargeIndicatorView", owner: self, topLevelObjects: &topLevelObjects)
    {
      view = topLevelObjects!.first(where: { $0 is NSView }) as? NSView
    }
    
    // Use bounds not frame or it'll be offset
    view?.frame = bounds
    
    // Make the view stretch with containing view
    view?.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
    
    if view != nil
    {
      self.addSubview(view!)
    }
  }
}
